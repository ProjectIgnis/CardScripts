--ラッキー・ボッス
--Lucky Boss
--Scripted by Eerie Code
function c120401054.initial_effect(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c120401054.indes)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(120401054,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,120401054)
	e2:SetCondition(c120401054.rmcon)
	e2:SetCost(c120401054.rmcost)
	e2:SetTarget(c120401054.rmtg)
	e2:SetOperation(c120401054.rmop)
	c:RegisterEffect(e2)
	--lp
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(120401054,1))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c120401054.lptg)
	e3:SetOperation(c120401054.lpop)
	c:RegisterEffect(e3)
	--replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e4:SetCountLimit(1)
	e4:SetTarget(c120401054.reptg)
	e4:SetValue(c120401054.repval)
	e4:SetOperation(c120401054.repop)
	c:RegisterEffect(e4)
end
function c120401054.indes(e,c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
function c120401054.rmcfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
function c120401054.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c120401054.rmcfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c120401054.rmfilter1(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(c120401054.rmfilter2,tp,LOCATION_DECK,0,1,nil,bit.band(c:GetType(),TYPE_SPELL+TYPE_TRAP))
end
function c120401054.rmfilter2(c,ty)
	return c:IsType(ty) and c:IsAbleToRemove()
end
function c120401054.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c120401054.rmfilter1,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c120401054.rmfilter1,tp,LOCATION_HAND,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(bit.band(g:GetFirst():GetType(),TYPE_SPELL+TYPE_TRAP))
end
function c120401054.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function c120401054.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c120401054.rmfilter2,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	local tg=g:GetFirst()
	if tg==nil then return end
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	e1:SetCondition(c120401054.thcon)
	e1:SetOperation(c120401054.thop)
	e1:SetLabel(0)
	tg:RegisterEffect(e1)
end
function c120401054.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c120401054.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	e:GetHandler():SetTurnCounter(ct+1)
	if ct==1 then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,e:GetHandler())
	else e:SetLabel(1) end
end
function c120401054.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,800)
end
function c120401054.lpop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
function c120401054.repfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsRace(RACE_WARRIOR)
		and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function c120401054.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c120401054.repfilter,1,nil,tp) end
	return Duel.SelectYesNo(tp,aux.Stringid(120401054,2))
end
function c120401054.repval(e,c)
	return c120401054.repfilter(c,e:GetHandlerPlayer())
end
function c120401054.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
