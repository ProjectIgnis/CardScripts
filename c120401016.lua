--綱引きガエル
--Frog-of-War
--Scripted by Eerie Code
function c120401016.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),2,2)
	--cannot be battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c120401016.atkcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	--control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(120401016,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,120401016)
	e2:SetCondition(c120401016.cncon)
	e2:SetCost(c120401016.cncost)
	e2:SetTarget(c120401016.cntg)
	e2:SetOperation(c120401016.cnop)
	c:RegisterEffect(e2)
end
function c120401016.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
function c120401016.atkcon(e)
	return Duel.IsExistingMatchingCard(c120401016.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function c120401016.cncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if lg:GetCount()~=2 then return end
	local a=lg:GetFirst()
	local d=lg:GetNext()
	if a:IsControler(1-tp) then a,d=d,a end
	if a:IsFaceup() and d:IsFaceup() and c:GetAttack()+a:GetAttack()~=d:GetAttack() and d:IsControlerCanBeChanged() then
		e:SetLabelObject(d)
		return true
	else return false end
end
function c120401016.cncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	local tc=lg:Filter(Card.IsControler,nil,tp):GetFirst()
	if chk==0 then return tc and tc:IsReleasable() end
	Duel.Release(tc,REASON_COST)
end
function c120401016.cntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
function c120401016.cnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local tc=c:GetLinkedGroup():Filter(Card.IsControler,nil,1-tp):GetFirst()
	if tc then
		Duel.GetControl(tc,tp)
	end
end
