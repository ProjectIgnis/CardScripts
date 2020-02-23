--ミラクル・ファイヤー
--Miracle Fire
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsType(TYPE_ACTION) and not rc:IsType(TYPE_FIELD) then
		rc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,0)
	end
end
function s.filter(c)
	return c:GetFlagEffect(id)>0 and c:CheckActivateEffect(false,false,false)~=nil
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	if not tg then return end
	local te=tg:GetFirst():GetActivateEffect()
	local cost=te:GetCost()
	local target=te:GetTarget()
	local operation=te:GetOperation()
	if cost then cost(e,tp,eg,ep,ev,re,r,rp) end
	if target then target(e,tp,eg,ep,ev,re,r,rp) end
	if operation then operation(e,tp,eg,ep,ev,re,r,rp) end
end
