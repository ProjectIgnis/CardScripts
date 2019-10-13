--ヘッド・ジャッジング
--Head Judging
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
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
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetCurrentChain()-1
	local te,p=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local g=Group.FromCards(te:GetHandler())
	if s.con(e,tp,g,ep,ct,te,r,p) and s.cost(e,tp,g,ep,ct,te,r,p,0) and s.tg(e,tp,g,ep,ct,te,r,p,0) 
		and Duel.SelectYesNo(tp,94) then
		e:SetCategory(CATEGORY_COIN+CATEGORY_TOGRAVE+CATEGORY_NEGATE+CATEGORY_CONTROL)
		s.cost(e,tp,g,ep,ct,te,r,p,1)
		s.tg(e,tp,g,ep,ct,te,r,p,1)
		e:SetOperation(s.activate(ct,te,p,g))
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function s.activate(ct,te,p,g)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				s.op(e,tp,g,ep,ct,te,r,p)
			end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave() and re:GetHandler():IsControlerCanBeChanged() end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,rp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,re:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,re:GetHandler(),1,0,0)
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

