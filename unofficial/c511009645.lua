--ミラーイマジン・プリズムコート８
--Mirror Imagine Prism Coat 8
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={0x572}
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,g1)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g1,#g1,tp,g2:GetFirst():GetAttack()/2)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local oc=g:GetFirst()
		if oc==tc then oc=g:GetNext() end
		if oc:IsFaceup() and oc:IsRelateToEffect(e) then
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_UPDATE_ATTACK)
			e0:SetValue(oc:GetAttack()/2)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e0)
		end
		local op=Duel.SelectOption(tp,aux.Stringid(35089369,1),aux.Stringid(2095764,1),aux.Stringid(65884091,0))
		if op==0 then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(35089369,1))
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SINGLE_RANGE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(s.efilterS)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		elseif op==1 then
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(2095764,1))
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SINGLE_RANGE)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EFFECT_IMMUNE_EFFECT)
			e2:SetValue(s.efilterT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		elseif op==2 then
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(65884091,0))
			e3:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SINGLE_RANGE)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetRange(LOCATION_MZONE)
			e3:SetCode(EFFECT_IMMUNE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3:SetValue(s.efilterM)
			tc:RegisterEffect(e3)
		end
	end
end
function s.efilterS(e,te)
	return te:IsActiveType(TYPE_SPELL) and e:GetHandlerPlayer()~=te:GetHandlerPlayer()
end
function s.efilterT(e,te)
	return te:IsActiveType(TYPE_TRAP) and e:GetHandlerPlayer()~=te:GetHandlerPlayer()
end
function s.efilterM(e,te)
	return te:IsActiveType(TYPE_MONSTER) and not te:GetHandler():IsSetCard(0x572)
end
