--ＥＭイグニッション・イーグル
--Performapal Ignition Eagle
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	--Destroy all cards in the Spell/Trap Zone and increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_PZONE)
	e1:SetHintTiming(TIMING_BATTLE_STEP_END,TIMING_BATTLE_STEP_END)
	e1:SetCondition(function() return Duel.GetCurrentPhase()==PHASE_BATTLE_STEP end)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Special Summon 1 card from your Pendulum Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(_,tp) return Duel.GetAttacker():IsControler(tp) end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PERFORMAPAL}
function s.cfilter(c)
	return c:IsSetCard(SET_PERFORMAPAL) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	local sct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_STZONE,LOCATION_STZONE,g)
	if chk==0 then return #g==g:FilterCount(Card.IsAbleToRemoveAsCost,nil) and sct>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,sct,nil) end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local gc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,sct,sct,nil)
	Duel.SendtoGrave(gc,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_PENDULUM),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_STZONE,LOCATION_STZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,PLAYER_ALL,LOCATION_STZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_STZONE,LOCATION_STZONE,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_PENDULUM),tp,LOCATION_MZONE,0,1,nil) then
		local pc=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_PENDULUM),tp,LOCATION_MZONE,0,nil)
		Duel.BreakEffect()
		--Increase ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(pc*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ac=Duel.GetAttacker()
	if chk==0 then return e:GetHandler():IsType(TYPE_PENDULUM) and ac:IsCanBeEffectTarget(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.SetTargetCard(ac)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp):GetFirst()
	if not sc or Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local atk=sc:GetAttack()
	if atk==0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:UpdateAttack(atk,nil,c)==atk and Duel.CheckPendulumZones(tp)
		and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end