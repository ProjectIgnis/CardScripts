--幻壊爆竜デンジャラス・バクハムート
--Demolition Charge Dragon Dangerous Blasthamut
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160208040,160208043)
	--Destroy 2 of opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
	if #g>0 and #g2>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,1,nil)
		local sg=g2:Select(tp,1,2,nil)
		dg:AddCard(sg)
		dg=dg:AddMaximumCheck()
		Duel.HintSelection(dg,true)
		if Duel.Destroy(dg,REASON_EFFECT)>0 then
			local ct=Duel.GetOperatedGroup():FilterCount(s.damfilter,nil,tp)
			Duel.Damage(1-tp,500*ct,REASON_EFFECT)
		end
	end
end
function s.damfilter(c,tp)
	return c:IsPreviousControler(1-tp) and not c:WasMaximumModeSide()
end