--N・アクア・ドルフィン (Anime)
--Neo Spacian Aqua Dolphin (Anime)
--Scripted by Astral
local s,id=GetID()
function s.initial_effect(c)
	--Look at your opponent's hand and choose 1 monster, if you control a monster with ATK greater than or equal to the ATK of the chosen card, destroy the chosen card, and if you do, inflict 500 damage to your opponent, otherwise, take 500 damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17955766,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(Cost.Discard())
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_HAND)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g==0 then return end
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local sc=g:FilterSelect(tp,Card.IsMonster,1,1,nil):GetFirst()
	if sc then
		local atk=sc:GetAttack()
		if sc:IsAttackAbove(0) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttackAbove,atk),tp,LOCATION_MZONE,0,1,nil) then
			if Duel.Destroy(sc,REASON_EFFECT)>0 then
				Duel.Damage(1-tp,500,REASON_EFFECT)
			end
		else
			Duel.Damage(tp,500,REASON_EFFECT)
		end
	end
	Duel.ShuffleHand(1-tp)
end
