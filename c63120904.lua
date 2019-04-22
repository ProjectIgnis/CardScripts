--暗黒大要塞鯱
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.rfilter(c)
	return c:IsCode(90337190,95614612)
end
function s.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==90337190 then return chkc:IsLocation(LOCATION_MZONE)
		else return chkc:IsOnField() and s.dfilter(chkc) end
	end
	local b1=Duel.CheckReleaseGroupCost(tp,Card.IsCode,1,false,nil,nil,90337190) and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b2=Duel.CheckReleaseGroupCost(tp,Card.IsCode,1,false,nil,nil,95614612) and Duel.IsExistingTarget(s.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local code=0
	if b1 and b2 then
		local rg=Duel.SelectReleaseGroupCost(tp,s.rfilter,1,1,false,nil,nil)
		code=rg:GetFirst():GetCode()
		Duel.Release(rg,REASON_COST)
	elseif b1 then
		local rg=Duel.SelectReleaseGroupCost(tp,Card.IsCode,1,1,false,nil,nil,90337190)
		code=90337190
		Duel.Release(rg,REASON_COST)
	else
		local rg=Duel.SelectReleaseGroupCost(tp,Card.IsCode,1,1,false,nil,nil,95614612)
		code=95614612
		Duel.Release(rg,REASON_COST)
	end
	e:SetLabel(code)
	if code==90337190 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,s.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
