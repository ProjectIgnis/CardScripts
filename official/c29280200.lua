--ＶＳＤｒ．マッドラヴ
--Vanquish Soul Dr. Mad Love
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Search 1 "Vanquish Soul" Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.opccost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Reduce 1 opponent's monster's ATK/DEF, OR send 1 face-up monster on the field to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E|TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.opccost)
	e3:SetTarget(s.vstg)
	e3:SetOperation(s.vsop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_VANQUISH_SOUL}
function s.opccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
function s.thfilter(c)
	return c:IsSetCard(SET_VANQUISH_SOUL) and c:IsSpellTrap() and c:IsAbleToHand()
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
function s.vscostfilter(c,att)
	return c:IsAttribute(att) and not c:IsPublic()
end
function s.vsrescon(sg)
	return sg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_DARK)>0
		and sg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_EARTH)>0
end
function s.vstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local not_dmg_step=Duel.GetCurrentPhase()~=PHASE_DAMAGE
	local cg1=Duel.GetMatchingGroup(s.vscostfilter,tp,LOCATION_HAND,0,nil,ATTRIBUTE_DARK)
	local fg1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local b1=#cg1>0 and #fg1>0 and (not_dmg_step or not Duel.IsDamageCalculated())
	local cg2=cg1+Duel.GetMatchingGroup(s.vscostfilter,tp,LOCATION_HAND,0,nil,ATTRIBUTE_EARTH)
	local fg2=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToHand),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local b2=#fg2>0 and aux.SelectUnselectGroup(cg2,e,tp,1,2,s.vsrescon,0) and not_dmg_step
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=cg1:Select(tp,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	elseif op==2 then
		local g=aux.SelectUnselectGroup(cg2,e,tp,1,2,s.vsrescon,1,tp,HINTMSG_CONFIRM,s.vsrescon)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_EITHER,LOCATION_MZONE)
	end
end
function s.vsop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local c=e:GetHandler()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if not tc then return end
		Duel.HintSelection(tc,true)
		tc:UpdateAttack(-500,RESET_EVENT|RESETS_STANDARD,c)
		tc:UpdateDefense(-500,RESET_EVENT|RESETS_STANDARD,c)
	elseif op==2 then
		local g2=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsDefenseAbove,0),tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetMinGroup(Card.GetDefense)
		if not g2 or #g2==0 then return end
		if #g2>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			g2=g2:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		end
		if #g2==0 then return end
		Duel.HintSelection(g2,true)
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
	end
end