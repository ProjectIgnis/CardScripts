--獣機界王カタパルト・デビルコング
--Beast Gear Emperor Catapult Kong
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Destroy up to 2 of opponent's defense position monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ctmax=Duel.GetMatchingGroupCount(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	if ctmax>2 then ctmax=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,ctmax,e:GetHandler())
	local ct=Duel.SendtoGrave(g,REASON_COST)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,ct,ct,nil)
		Duel.HintSelection(dg)
		if #dg>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end