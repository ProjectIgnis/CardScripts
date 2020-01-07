--ＳｐTakeover
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.con)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	return tc and tc:GetCounter(0x91)>3
end
function s.filter(c)
	return c:IsFaceup() and c:GetCounter(0)~=0 and c:IsDestructable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetCounter(0)*100)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local lp=tc:GetCounter(0)*100
	if tc:GetCounter(0x3001)>0 then
		lp=lp+(tc:GetCounter(0x3001)*100)
	end
	if tc:GetCounter(0x100)>0 then
		lp=lp+(tc:GetCounter(0x100)*100)
	end
	if tc:GetCounter(0xe)>0 then
		lp=lp+(tc:GetCounter(0xe)*100)
	end
	if tc:GetCounter(0x15)>0 then
		lp=lp+(tc:GetCounter(0x15)*100)
	end
	if tc:GetCounter(0x19)>0 then
		lp=lp+(tc:GetCounter(0x19)*100)
	end
	if tc:GetCounter(0xf)>0 then
		lp=lp+(tc:GetCounter(0xf)*100)
	end
	if tc:GetCounter(0x1f)>0 then
		lp=lp+(tc:GetCounter(0x1f)*100)
	end
	if tc:GetCounter(0x8)>0 then
		lp=lp+(tc:GetCounter(0x8)*100)
	end
	if tc:GetCounter(0x10)>0 then
		lp=lp+(tc:GetCounter(0x10)*100)
	end
	if tc:GetCounter(0x20)>0 then
		lp=lp+(tc:GetCounter(0x20)*100)
	end
	if tc:GetCounter(0x99)>0 then
		lp=lp+(tc:GetCounter(0x99)*100)
	end
	if Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Recover(tp,lp,REASON_EFFECT)
	end
end
