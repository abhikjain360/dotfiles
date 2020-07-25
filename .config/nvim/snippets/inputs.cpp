#include <iostream>
#include <fstream>
#include <vector>
#include <boost/algorithm/string.hpp>
#include <string>

typedef long long ll;

int main()
{
	std::ifstream fin("inputfile");
	std::ofstream fout("outputfile");

	std::string inputline;
	std::vector<std::string> inputs;
	std::vector<ll> nums;
	ll arrSize;

	while (getline(fin,inputline))
	{
		boost::algorithm::split(inputs,inputline,boost::is_any_of(" "));

		arrSize = inputs.size();

		nums.reserve(arrSize);
		for (auto i:inputs)
			nums.push_back(std::stoll(i));

		nums.clear();
		nums.shrink_to_fit();
		inputs.clear();
		inputs.shrink_to_fit();
	}

	fin.close();
	fout.close();

	return 0;
}
