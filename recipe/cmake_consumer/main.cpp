#include <GraphMol/GraphMol.h>
#include <GraphMol/MolDraw2D/MolDraw2DSVG.h>
#include <GraphMol/SmilesParse/SmilesParse.h>
#include <GraphMol/SmilesParse/SmilesWrite.h>

#include <iostream>
#include <memory>

int main() {
  std::unique_ptr<RDKit::ROMol> mol(RDKit::SmilesToMol("OC1=CC=CC=C1"));
  if (!mol || RDKit::MolToSmiles(*mol) != "Oc1ccccc1") {
    return 1;
  }
  RDKit::MolDraw2DSVG drawer(200, 200);
  drawer.drawMolecule(*mol);
  drawer.finishDrawing();
  if (drawer.getDrawingText().find("<svg") == std::string::npos) {
    return 1;
  }
  std::cout << "consumer ok: " << RDKit::MolToSmiles(*mol) << std::endl;
  return 0;
}
