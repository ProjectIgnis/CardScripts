--ティンクル・ファイブスター (Anime)
--Five Star Twilight (Anime)
local s,id=GetID()
local LOCATION_HDG = LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_KURIBOH,44632120,71036835,34419588,7021574} --"Kuriboh", "Kuribah", "Kuribee", "Kuribeh", "Kuriboo"
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==1 and g:GetFirst():IsLevel(5) and g:GetFirst():IsFaceup()
end
function s.costfilter(c,ft,tp)
	return c:IsLevel(5) and (ft>4 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>=4 and Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,ft,tp) end
	local rg=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,ft,tp)
	Duel.Release(rg,REASON_COST)
end
function s.spcheck(sg,e,tp)
	return #sg==5 and sg:IsExists(Card.IsCode,1,nil,CARD_KURIBOH) and sg:IsExists(Card.IsCode,1,nil,44632120) 
		and sg:IsExists(Card.IsCode,1,nil,71036835) and sg:IsExists(Card.IsCode,1,nil,34419588)
		and sg:IsExists(Card.IsCode,1,nil,7021574)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)	
	if chk==0 then
		local g=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,LOCATION_HDG,0,nil,e,0,tp,false,false)
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<5 then return false end
		e:SetLabel(0)
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and aux.SelectUnselectGroup(g,e,tp,5,5,s.spcheck,0)  
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,5,tp,LOCATION_HDG)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<5 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,LOCATION_HDG,0,nil,e,0,tp,false,false)
	local sg=aux.SelectUnselectGroup(g,e,tp,5,5,s.spcheck,1,tp,HINTMSG_SPSUMMON)
	if #sg==5 then
		for tc in sg:Iter() do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3304)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			e1:SetValue(1)
			tc:RegisterEffect(e1,true)
		end
		Duel.SpecialSummonComplete()
	end
end
