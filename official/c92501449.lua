--原石の鳴獰
--Primite Roar
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Prevent battle destruction and Special Summon 1 Normal Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(Cost.PayLP(2000))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Banish 1 monster on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.rmvtg)
	e2:SetOperation(s.rmvop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PRIMITE}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.announce_filter={TYPE_NORMAL,OPCODE_ISTYPE}
	local code=Duel.AnnounceCard(tp,s.announce_filter)
	Duel.SetTargetParam(code)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp,code)
	return c:IsType(TYPE_NORMAL) and c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	--Your Normal Monsters with the declared name and "Primite" monsters cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(SET_PRIMITE) or (c:IsCode(code) and c:IsType(TYPE_NORMAL)) end)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2),RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp,code)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.BreakEffect()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.tgfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetAttack())
end
function s.rmvfilter(c,atk)
	return c:IsAbleToRemove() and c:IsFaceup() and c:GetAttack()<atk
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local atk=tc:GetAttack()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,nil,REASON_EFFECT)
	end
end