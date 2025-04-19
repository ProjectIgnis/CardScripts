--ブラック・ドラゴンズ・デーモン
--Black Dragon Skull Archfiend
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_SUMMONED_SKULL,CARD_REDEYES_B_DRAGON)
	--ATK increase
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_REDEYES_B_DRAGON,CARD_SUMMONED_SKULL}
s.material_setcode={SET_RED_EYES,SET_ARCHFIEND }
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttackBelow,3100),tp,0,LOCATION_MZONE,nil)
	if chk==0 then return Duel.GetFieldGroupCountRush(tp,LOCATION_MZONE,0)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(3100) and c:IsNotMaximumModeSide()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end