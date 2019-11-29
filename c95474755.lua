--No.89 電脳獣ディアブロシス
--Number 89: Diablosis the Mind Hacker
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	--banish extra
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.excost)
	e1:SetTarget(s.extg)
	e1:SetOperation(s.exop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--banish grave
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.grcon)
	e2:SetTarget(s.grtg)
	e2:SetOperation(s.grop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	--banish deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.dkcon)
	e4:SetTarget(s.dktg)
	e4:SetOperation(s.dkop)
	c:RegisterEffect(e4)
end
s.xyz_number=89
function s.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil,tp,POS_FACEDOWN) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
function s.exop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp,POS_FACEDOWN)
	Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	Duel.ShuffleExtra(1-tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
function s.grcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.rmfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and aux.SpElimFilter(c)
end
function s.grtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.grop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
function s.dkfilter(c,p)
	return c:IsFacedown() and c:IsControler(p)
end
function s.dkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.dkfilter,1,nil,1-tp)
end
function s.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.dkfilter,tp,0,LOCATION_REMOVED,nil,1-tp)
	local tg=Duel.GetDecktopGroup(1-tp,ct)
	if chk==0 then return ct>0
		and tg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==ct end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_DECK)
end
function s.dkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.dkfilter,tp,0,LOCATION_REMOVED,nil,1-tp)
	if ct==0 then return end
	local tg=Duel.GetDecktopGroup(1-tp,ct)
	Duel.DisableShuffleCheck()
	Duel.Remove(tg,POS_FACEDOWN,REASON_EFFECT)
end
