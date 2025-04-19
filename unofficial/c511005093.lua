--Booster Draft Duel (HIJACK)
--Scripted by edo9300
local id=511005093
if self_table then
	function self_table.initial_effect(c) end
end

--define pack
--pack=BP03
--[1]=rare, [2/3/4]=common, [5]=foil
local pack={}
	pack[1]={
		42364374,71413901,82108372,39168895,78636495,42386471,16956455,85306040,89222931,85087012,18430390,
		61802346,39303359,54040221,52319752,14089428,76203291,75081613,96235275,41113025,6061630,92826944,
		84847656,74976215,69695704,45041488,12435193,80925836,42463414,77135531,10321588,4694209,39037517,
		37792478,49680980,82199284,20474741,83957459,66816282,91438994,62950604,47013502,85682655,4611269,
		95905259,1371589,66499018,64892035,40921545,98225108,42969214,97396380,89362180,15767889,50896944
	}
	pack[2]={
		23635815,40133511,38742075,77491079,40320754,30914564,76909279,2671330,18325492,55424270,3370104,
		93130021,21074344,94689635,99861526,79409334,12398280,20586572,46508640,95943058,91596726,52035300,
		87685879,39180960,59797187,11232355,17266660,52430902,38041940,2525268,95090813,71759912,90508760,
		43426903,65422840,79337169,3603242,23927545,20351153,13521194,12235475,96930127,2137678,84747429,
		73625877,93830681,5237827,2584136,49374988,72429240,7914843,30464153,78663366,30608985,54635862
	}
	pack[3]={
		37984162,61318483,12467005,99733359,25727454,72302403,70046172,86198326,70828912,82432018,19230407,
		73915051,95281259,55991637,81385346,37684215,31036355,2204140,4861205,10012614,28106077,98045062,
		82828051,12923641,36045450,37534148,1353770,6178850,4230620,62991886,99995595,35480699,45247637,
		32180819,44887817,92346415,25789292,95507060,91580102,25518020,66835946,98867329,84428023,78082039,
		27243130,67775894,60398723,53610653,89882100,88616795,73199638,36042825,96864811,83438826,23562407
	}
	pack[4]={
		42502956,54773234,52112003,88610708,97077563,22359980,68540058,57882509,41925941,31785398,80163754,
		98239899,3149764,59744639,83133491,29267084,66742250,12503902,96008713,77538567,4923662,60306104,
		93895605,34815282,82633308,23323812,59718521,37390589,91078716,54451023,97168905,73729209,17490535,
		43889633,16678947,87106146,32854013,21636650,89792713,3146695,25642998,11741041,75987257,44046281,
		78474168,44509898,71098407,63630268,23122036,25005816,51099515,88494120,14883228,50277973,87772572
	}
	pack[5]={
		47506081,95992081,11411223,47805931,3989465,76372778,581014,12014404,48009503,74593218,57043117,
		95169481,66506689,51960178,80764541,75367227,68836428
	}
	for _,v in ipairs(pack[1]) do table.insert(pack[5],v) end
	for _,v in ipairs(pack[2]) do table.insert(pack[5],v) end
	for _,v in ipairs(pack[3]) do table.insert(pack[5],v) end
	for _,v in ipairs(pack[4]) do table.insert(pack[5],v) end

--before anything
if not BoosterDraft then
	BoosterDraft={}
	local function finish_setup() 
		--Pre-draw
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_STARTUP)
		e1:SetCountLimit(1)
		e1:SetOperation(BoosterDraft.op)
		Duel.RegisterEffect(e1,0)
	end
	local c_getrace=Card.GetRace
	Card.GetRace=function(c)
		if c:IsMonster() then return 0xffffff end
		return c_getrace(c)
	end
	local c_getorigrace=Card.GetOriginalRace
	Card.GetOriginalRace=function(c)
		if c:IsMonster() then return 0xffffff end
		return c_getorigrace(c)
	end
	local c_getprevraceonfield=Card.GetPreviousRaceOnField
	Card.GetPreviousRaceOnField=function(c)
		if (c:GetPreviousTypeOnField()&TYPE_MONSTER)~=0 then return 0xffffff end
		return c_getprevraceonfield(c)
	end
	local c_israce=Card.IsRace
	Card.IsRace=function(c,r)
		if c:IsMonster() then return true end
		return c_israce(c,r)
	end

	function BoosterDraft.op(e,tp,eg,ep,ev,re,r,rp)
		local z,o=tp,1-tp
		--Hint
		local counts={}
		counts[0]=Duel.GetPlayersCount(0)
		counts[1]=Duel.GetPlayersCount(1)
		Duel.DisableShuffleCheck()
		Duel.Hint(HINT_CARD,0,id)
		
		for p=z,o do
			for team=1,counts[p] do
				Duel.RemoveCards(Duel.GetFieldGroup(p,0xff,0),0,-2,REASON_RULE)
				if counts[p]~=1 then
					Duel.TagSwap(p)
				end
			end
		end
		
		local groups={}
		groups[0]={}
		groups[1]={}
		for i=1,counts[0] do
			groups[0][i]={}
		end
		for i=1,counts[1] do
			groups[1][i]={}
		end
		
		local function generate_packs()
			local total=(counts[0]+counts[1])*3
			local retpacks={}
			for t=1,total do
				local _pack={}
				for p=1,3 do
					for i=1,5 do
						local cpack=pack[i]
						local c=cpack[Duel.GetRandomNumber(1,#cpack)]
						table.insert(_pack,c)
					end
				end
				table.insert(retpacks,_pack)
			end
			return retpacks
		end
		local packs = generate_packs()
		local pack=table.remove(packs, 1)
		while pack do
			for p=z,o do
				for team=1,counts[p] do
					local tc=Duel.SelectCardsFromCodes(p,1,1,false,true,table.unpack(pack))
					table.insert(groups[p][team],tc[1])
					table.remove(pack, tc[2])
					if counts[p]~=1 then
						Duel.TagSwap(p)
					end
					if #pack==0 then
						pack=table.remove(packs, 1)
						if not pack then goto exit end
					end
				end
			end
		end
		::exit::
		for p=z,o do
			for team=1,counts[p] do
				for _,card in ipairs(groups[p][team]) do
					Debug.AddCard(card,p,p,LOCATION_DECK,1,POS_FACEDOWN)
				end
				if counts[p]~=1 then
					Duel.TagSwap(p)
				end
			end
		end
		Debug.ReloadFieldEnd()
		for p=z,o do
			for team=1,counts[p] do
				Duel.ShuffleDeck(p)
				if counts[p]~=1 then
					Duel.TagSwap(p)
				end
			end
		end
		local tck0=Duel.CreateToken(0,946)
		xyztempg0:AddCard(tck0)
		local tck1=Duel.CreateToken(1,946)
		xyztempg1:AddCard(tck1)
		e:Reset()
	end
	finish_setup()
end