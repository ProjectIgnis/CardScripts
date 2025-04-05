--レアル・クルセイダー
--Absolute Crusader
local s,id=GetID()
function s.initial_effect(c)
	--Destroy level 5 or higher monsters that are Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.descond)
	e1:SetCost(Cost.SelfTribute)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5)
end
function s.descond(e,tp,eg,ep,ev,re,r,rp,chk)
	return eg:IsExists(s.desfilter,1,e:GetHandler())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dg=eg:Filter(s.desfilter,e:GetHandler(),nil)
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:Filter(s.desfilter,nil):Filter(Card.IsRelateToEffect,nil,e)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end