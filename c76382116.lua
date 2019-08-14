--鉄の王 ドヴェルグス
--Dvergs, Generaid of Iron
--Scripted by AlphaKretin and Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x134}
function s.cfilter(c)
	return c:IsSetCard(0x134) or c:IsRace(RACE_MACHINE)
end
function s.filter(c,e,tp)
	return (c:IsSetCard(0x134) or c:IsRace(RACE_MACHINE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.check(g)
	return  function(sg,tp)
				local codes=sg:GetClass(Card.GetCode)
				return aux.ChkfMMZ(#sg)(sg,nil,tp) 
					and g:Filter(aux.NOT(Card.IsCode),nil,table.unpack(codes)):GetClassCount(Card.GetCode)>=#sg
			end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e,tp)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,s.check(g),nil) end
	local max=5
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then max=1 end
	local rg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,max,false,s.check(g),nil)
	Duel.Release(rg,REASON_COST)
	local og=Duel.GetOperatedGroup()
	og:KeepAlive()
	e:SetLabelObject(og)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rg=e:GetLabelObject()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#rg,tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rg=e:GetLabelObject()
	local codes=rg:GetClass(Card.GetCode)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e,tp):Filter(aux.NOT(Card.IsCode),nil,table.unpack(codes))
	local ct=math.min(#rg,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if #g>0 and ct>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
		local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	rg:DeleteGroup()
end