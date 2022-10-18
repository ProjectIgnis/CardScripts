-- トリヴィカルマ
--Trivikarma
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Negate target's effect and increase the ATK of "Visas Starfrost"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Search 1 card that lists "Visas Starfrost"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_VISAS_STARFROST,id}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
		and ((c:IsCode(CARD_VISAS_STARFROST) and c:IsControler(tp))
		or (c:IsControler(1-tp) and c:IsType(TYPE_EFFECT) and c:IsNegatableMonster()))
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	local hg=tg:Filter(Card.IsControler,nil,tp)
	e:SetLabelObject(hg:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tg:Filter(Card.IsControler,nil,1-tp),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,hg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc2==e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	if tc2 and tc2:IsControler(1-tp) and tc2:IsFaceup() and not tc2:IsDisabled() and not tc2:IsImmuneToEffect(e) then
		local c=e:GetHandler()
		Duel.NegateRelatedChain(tc2,RESET_TURN_SET)
		--Negate the effects of the opponent's monster
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e2)
		local val=math.max(tc2:GetBaseAttack(),tc2:GetBaseDefense())/2
		if val==0 then return end
		--Your monster gains half of the original ATK/DEF (whichever is higher)
		if tc1 and tc1:IsControler(tp) and tc1:IsRelateToEffect(e) and tc1:IsFaceup() then
			tc1:UpdateAttack(val,RESET_EVENT+RESETS_STANDARD,c)
		end
	end
end
function s.thfilter(c)
	return c:ListsCode(CARD_VISAS_STARFROST) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end