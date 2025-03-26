--真紅眼の凶雷皇－エビル・デーモン
--Red-Eyes Archfiend of Lightning
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	--Destroy opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(Gemini.EffectStatusCondition)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.filter(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk-1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetAttack()
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,atk)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local atk=c:GetAttack()
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,atk)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end