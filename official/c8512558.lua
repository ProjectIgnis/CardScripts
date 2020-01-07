--希望皇オノマトピア
--Utopic Onomatopeia
--Scripted by Logical Nonsense and AlphaKretin, revised handling of archetype check by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Add setcode
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetValue(0x54)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetValue(0x59)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetValue(0x82)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetValue(0x8f)
	c:RegisterEffect(e5)
end
s.listed_series={0x54,0x59,0x82,0x8f}
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and (c:IsSetCard(0x54) or c:IsSetCard(0x59) or c:IsSetCard(0x82) or  c:IsSetCard(0x8f)) and not c:IsCode(id)
end
function s.get_series(c)
	local res={}
	if c:IsSetCard(0x54) then table.insert(res,1) end
	if c:IsSetCard(0x59) then table.insert(res,2) end
	if c:IsSetCard(0x82) then table.insert(res,4) end
	if c:IsSetCard(0x8f) then table.insert(res,8) end
	return res
end
function bitsplit(n)
	local t={}
	if n>7 then n=n-8 table.insert(t,8) end
	if n>3 then n=n-4 table.insert(t,4) end
	if n>1 then n=n-2 table.insert(t,2) end
	if n>0 then n=n-1 table.insert(t,1) end
	table.sort(t)
	return t
end
function s.rescon(c,sg,arch_tab,e,tp,mg)
	if not aux.ChkfMMZ(#sg)(sg,e,tp,mg) then return false end
	local arch_lst=s.get_series(c)
	for _,ar in ipairs(arch_lst) do
		for __,chk in ipairs(arch_tab) do
			if (ar&chk)==0 then
				return true
			end
		end
	end
	return false
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>0 and g:IsExists(s.rescon,1,nil,Group.CreateGroup(),{0},e,tp,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function update_table(global_table,c)
	local tmp_table={}
	local arch_lst=s.get_series(c)
	for _,ar in ipairs(arch_lst) do
		for __,chk in ipairs(global_table) do
			if (ar&chk)==0 then
				table.insert(tmp_table,ar|chk)
			end
		end
	end
	return tmp_table
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),4)
	if #g>0 and ft>0 then 
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local sg=Group.CreateGroup()
		local arch_tab={0}
		while #sg<ft do
			local mg=g:Filter(s.rescon,sg,sg,arch_tab,e,tp,g)
			if #mg==0 then break end
			local tc=mg:SelectUnselect(sg,tp,#sg>0,#sg>0)
			if not tc then break end
			if sg:IsContains(tc) then
				sg:RemoveCard(tc)
				arch_tab={0}
				for card in aux.Next(sg) do
					arch_tab=update_table(arch_tab,card)
				end
			else
				sg:AddCard(tc)
				arch_tab=update_table(arch_tab,tc)
			end		
		end
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end 
	local ge1=Effect.CreateEffect(e:GetHandler())
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ge1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge1:SetTargetRange(1,0)
	ge1:SetTarget(s.splimit)
	ge1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
	e2:SetDescription(aux.Stringid(id,5))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end