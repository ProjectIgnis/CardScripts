--Booster Draft Duel (HIJACK)
-- - Works with Single Duel

local s,id=GetID()

--before anything
if not s.rc_ovr then
	s.rc_ovr=true
	local c_getrace=Card.GetRace
	Card.GetRace=function(c)
		if c:IsType(TYPE_MONSTER) then return 0xffffff end
		return c_getrace(c)
	end
	local c_getorigrace=Card.GetOriginalRace
	Card.GetOriginalRace=function(c)
		if c:IsType(TYPE_MONSTER) then return 0xffffff end
		return c_getorigrace(c)
	end
	local c_getprevraceonfield=Card.GetPreviousRaceOnField
	Card.GetPreviousRaceOnField=function(c)
		if (c:GetPreviousTypeOnField()&TYPE_MONSTER)~=0 then return 0xffffff end
		return c_getprevraceonfield(c)
	end
	local c_israce=Card.IsRace
	Card.IsRace=function(c,r)
		if c:IsType(TYPE_MONSTER) then return true end
		return c_israce(c,r)
	end
end

function s.initial_effect(c)
	if s.regok then return end
	s.regok=true
	--Pre-draw
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,0)
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
local packopen=false
local handnum={[0]=5;[1]=5}

--DangerZone
--(Disabled)

local skip_effects={}

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if packopen then e:Reset() return end
	packopen=true
	Duel.DisableShuffleCheck()
	--Hint
	Duel.Hint(HINT_CARD,0,id)
	for p=0,1 do
		local c=Duel.CreateToken(p,id)
		Duel.Remove(c,POS_FACEUP,REASON_RULE)
		Duel.Hint(HINT_CODE,p,id)
		--protection (steal Boss Duel xD)
		local e10=Effect.CreateEffect(c)
		e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e10:SetType(EFFECT_TYPE_SINGLE)
		e10:SetCode(EFFECT_CANNOT_TO_GRAVE)
		c:RegisterEffect(e10)
		local e11=e10:Clone()
		e11:SetCode(EFFECT_CANNOT_TO_HAND)
		c:RegisterEffect(e11)
		local e12=e10:Clone()
		e12:SetCode(EFFECT_CANNOT_TO_DECK) 
		c:RegisterEffect(e12)
		local e13=e10:Clone()
		e13:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		c:RegisterEffect(e13)
	end
	--note hand card
	handnum[0]=5 --Duel.GetFieldGroupCount(0,LOCATION_HAND,0)
	handnum[1]=5 --Duel.GetFieldGroupCount(1,LOCATION_HAND,0)
	--SetLP
	Duel.SetLP(0,8000)
	Duel.SetLP(1,8000)
	--FOR RANDOOM
	local rseed=Duel.GetRandomNumber()
	math.randomseed(rseed)
	local fg=Duel.GetFieldGroup(0,0x43,0x43)
	--remove all cards
	Duel.SendtoDeck(fg,nil,-2,REASON_RULE)
	--Open packs
	--SKIP
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	Duel.RegisterEffect(e1,0)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SKIP_M1)
	Duel.RegisterEffect(e2,0)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_SKIP_BP)
	Duel.RegisterEffect(e3,0)
	e:Reset()
	local e4=e1:Clone()
	e3:SetCode(EFFECT_SKIP_M2)
	Duel.RegisterEffect(e4,0)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_CANNOT_BP)
	Duel.RegisterEffect(e5,0)
	local e6=e1:Clone()
	e6:SetCode(EFFECT_CANNOT_M2)
	Duel.RegisterEffect(e6,0)
	local e7=e1:Clone()
	e7:SetCode(EFFECT_CANNOT_EP)
	Duel.RegisterEffect(e7,0)
	table.insert(skip_effects,e1)
	table.insert(skip_effects,e2)
	table.insert(skip_effects,e3)
	table.insert(skip_effects,e4)
	table.insert(skip_effects,e5)
	table.insert(skip_effects,e6)
	table.insert(skip_effects,e7)
	local e5=Effect.CreateEffect(e:GetHandler())
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
	e5:SetCountLimit(1)
	e5:SetCondition(s.nt_cd)
	e5:SetOperation(s.nt_op)
	Duel.RegisterEffect(e5,0)
	e:Reset()
end

--Checks

function s.flag_chk(c)
	return c:GetFlagEffect(id)==0
end

function s.nt_cd(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()>0
end

local playerpack=Group.CreateGroup()
local playerpick={[0]={},[1]={},[2]={},[3]={}}
local confirmchk=999
local nump=2
local p2_exists=false
local p3_exists=false
local postprocess=false

function s.nt_op(e,tp,eg,ep,ev,re,r,rp)
	local tcount=Duel.GetTurnCount()
	local tplayer=Duel.GetTurnPlayer()
	if tcount<=4 then --determine 3rd/4th player
		if Duel.IsExistingMatchingCard(s.flag_chk,tplayer,0x43,0,1,nil) then
			local fg=Duel.GetFieldGroup(tplayer,0x43,0x43)
			--remove all cards
			Duel.SendtoDeck(fg,nil,-2,REASON_RULE)
			if tcount==2 then
				p2_exists=true
				nump=3
			end
			if tcount==3 then
				p3_exists=true
				nump=4
			end
		end
	elseif not postprocess then --go ahead and pick cards
		if nump==3 and tcount%4==3 then return end
		Duel.DisableShuffleCheck()
		local ppick
		if nump==3 and tcount%4==0 then
			ppick=playerpick[2]
		elseif nump==2 then
			ppick=playerpick[tplayer]
		else
			ppick=playerpick[(tcount-1)%4]
		end
		--Pick one
		if #playerpack==0 then
			for p=1,3 do
				for i=1,5 do
					local cpack=pack[i]
					local c=cpack[math.random(#cpack)]
					playerpack:AddCard(Duel.CreateToken(tplayer,c))
				end
			end
			if nump==2 then
				Duel.SendtoHand(playerpack,nil,REASON_RULE)
				Duel.SendtoDeck(playerpack:Filter(Card.IsLocation,nil,LOCATION_HAND),nil,0,REASON_RULE)
				confirmchk=tcount
			end
		end
		if nump==2 and tcount>confirmchk then
			Duel.ConfirmCards(tplayer,playerpack)
			confirmchk=999
		elseif nump>2 then
			Duel.SendtoHand(playerpack,nil,REASON_RULE)
			Duel.SendtoDeck(playerpack:Filter(Card.IsLocation,nil,LOCATION_HAND),nil,0,REASON_RULE)
			Duel.ConfirmCards(tplayer,playerpack)
		end
		Duel.Hint(HINT_SELECTMSG,tplayer,HINTMSG_TODECK)
		local rc=playerpack:Select(tplayer,1,1,nil):GetFirst()
		--local rc=playerpack:RandomSelect(tplayer,1):GetFirst() --testing purpose
		playerpack:RemoveCard(rc)
		Duel.SendtoDeck(rc,nil,-2,REASON_RULE)
		if nump>2 then Duel.SendtoDeck(playerpack,nil,-2,REASON_RULE) end
		table.insert(ppick,rc:GetOriginalCode())
		if #playerpick[0]>=45 and #playerpick[1]>=45 and (not p2_exists or #playerpick[2]>=45) and (not p3_exists or #playerpick[3]>=45) then
			Duel.SendtoDeck(playerpack,nil,-2,REASON_RULE)
			postprocess=true
		end
	--end go ahead
	else --postprocess
		if Duel.GetFieldGroupCount(tplayer,LOCATION_DECK+LOCATION_HAND,0)==0 then
			if nump==3 and tcount%4==3 then return end
			local ppick
			if nump==3 and tcount%4==0 then
				ppick=playerpick[2]
			elseif nump==2 then
				ppick=playerpick[tplayer]
			else
				ppick=playerpick[(tcount-1)%4]
			end
			local g=Group.CreateGroup()
			for _,c in ipairs(ppick) do
				g:AddCard(Duel.CreateToken(tplayer,c))
			end
			Duel.DisableShuffleCheck()
			Duel.SendtoHand(g,nil,REASON_RULE)
			Duel.SendtoDeck(g:Filter(Card.IsLocation,nil,LOCATION_HAND),nil,0,REASON_RULE)
			Duel.ShuffleDeck(tplayer)
			Duel.SendtoHand(Duel.GetDecktopGroup(tplayer,5),nil,REASON_RULE)
			if Duel.SelectYesNo(tplayer,aux.Stringid(4002,2)) then
				local sg=Duel.GetFieldGroup(tplayer,LOCATION_HAND,0)
				local ct=#sg
				Duel.SendtoDeck(sg,nil,1,REASON_RULE)
				Duel.SendtoHand(Duel.GetDecktopGroup(tplayer,ct),nil,REASON_RULE)
			end
		elseif tcount%4==1 then
			--resets
			for _,ske in ipairs(skip_effects) do
				ske:Reset()
			end
			--no attack this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_BP)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,1)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,0)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_M2)
			Duel.RegisterEffect(e2,0)
			e:Reset()
		end
	end
end
