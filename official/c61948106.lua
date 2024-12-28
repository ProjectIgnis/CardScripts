--ガトムズの非常召集
--Gottoms' Second Call
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 2 "X-Saber" monsters from your GY ignoring their Summoning conditions
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_X_SABER}
function s.spconfilter(c)
	return c:IsSetCard(SET_X_SABER) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPhase(PHASE_MAIN2) end
	--You cannot conduct your Battle Phase the turn you activate this card
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_X_SABER) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local tg=Duel.GetTargetCards(e):Match(s.spfilter,nil,e,tp)
	if #tg~=2 then return end
	local c=e:GetHandler()
	for tc in tg:Iter() do
		if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
			--Change their ATK to 0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
	--Destroy them during the End Phase of this turn
	aux.DelayedOperation(tg,PHASE_END,id,e,tp,function(ag) Duel.Destroy(ag,REASON_EFFECT) end,nil,nil,nil,aux.Stringid(id,2))
end