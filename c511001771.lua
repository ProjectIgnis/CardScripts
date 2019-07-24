--Guardian Eatos
local s,id=GetID()
function s.initial_effect(c)
	--sum limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(s.sumlimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(s.spcon)
	c:RegisterEffect(e4)
	--remove
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(s.rmcost)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
end
s.listed_names={55569674}
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(55569674)
end
function s.sumlimit(e)
	return not Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.eqfilter(c)
	return c:IsCode(55569674) and c:IsDestructable()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(s.eqfilter,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,s.eqfilter,1,1,nil)
	Duel.Destroy(g,REASON_COST)
end
function s.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFieldCard(1-tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)-1)
	if chk==0 then return tc and tc:IsType(TYPE_MONSTER) and tc:IsAbleToRemove() and tc:GetAttack()>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFieldCard(1-tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)-1)
	local sum=0
	while tc and tc:IsType(TYPE_MONSTER) and tc:IsAbleToRemove() and tc:GetAttack()>0 do
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		sum=sum+tc:GetAttack()
		tc=Duel.GetFieldCard(1-tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)-1)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(sum)
	c:RegisterEffect(e1)
end
