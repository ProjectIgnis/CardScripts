--ヘッド・ジャッジング
--Head Judging
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--coin
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COIN+CATEGORY_TOGRAVE+CATEGORY_NEGATE+CATEGORY_CONTROL)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
s.toss_coin=true
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and re:GetActivateLocation()&LOCATION_ONFIELD>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave()
		and (not re:GetHandler():IsRelateToEffect(re) or re:GetHandler():IsAbleToChangeControler()) end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,rp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,re:GetHandler(),1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,re:GetHandler(),1,0,0)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local coin=Duel.SelectOption(tp,60,61)
	local res=Duel.TossCoin(rp,1)
	if coin~=res then
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	else
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			Duel.GetControl(re:GetHandler(),1-rp)
		end
	end
end
