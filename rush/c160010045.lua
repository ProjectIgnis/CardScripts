-- エクリプス
-- Eclipse
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Destroy 1 monster on each field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.desrescon(sg,e,tp,mg)
	local a,b=sg:GetFirst(),sg:GetNext()
	return b and a:IsLevel(b:GetLevel()) and not a:IsControler(b:GetControler())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroupRush(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.desrescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,PLAYER_ALL,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupRush(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.desrescon,1,tp,HINTMSG_DESTROY)
	if #dg==2 then
		Duel.HintSelection(dg,true)
		Duel.Destroy(dg:AddMaximumCheck(),REASON_EFFECT)
	end
end