--同族感染ウィルス
--Tribe-Infecting Virus
local s,id=GetID()
function s.initial_effect(c)
	--Discard 1 card, then declare 1 Monster Type; destroy all monsters on the field with the declared Type
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(Cost.Discard())
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local monster_types=g:GetBitwiseOr(Card.GetRace)
	if chk==0 then return monster_types>0 end
	local declared_type=Duel.AnnounceRace(tp,1,monster_types)
	g:Match(Card.IsRace,nil,declared_type)
	e:GetChainData().declared_type=declared_type
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local declared_type=e:GetChainData().declared_type
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,declared_type),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end