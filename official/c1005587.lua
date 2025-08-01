--煉獄の落とし穴
--Void Trap Hole
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.disfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsAttackAbove(2000) and c:IsNegatableMonster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.disfilter,nil,tp)
	if chk==0 then return #g>0 end
	for sc in g:Iter() do
		sc:CreateEffectRelation(e)
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.disfilter,nil,tp):Match(Card.IsRelateToEffect,nil,e)
	if #g==0 then return end
	local sc=nil
	if #g==1 then
		sc=g:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.HintSelection(sc)
	end
	if sc:IsCanBeDisabledByEffect(e) then
		--Negate its effects
		sc:NegateEffects(e:GetHandler())
		Duel.AdjustInstantly(sc)
		if sc:IsDisabled() then
			Duel.Destroy(sc,REASON_EFFECT)
		end
	end
end