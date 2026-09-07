--エクトプラズマー
--Ectoplasmer
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--The turn player must Tribute 1 face-up monster, and if they do, inflict damage to their opponent equal to half the original ATK of the Tributed monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.tribtg)
	e1:SetOperation(s.tribop)
	c:RegisterEffect(e1)
end
function s.tribtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local turn_player=Duel.GetTurnPlayer()
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,turn_player,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-turn_player,0)
end
function s.tribop(e,tp,eg,ep,ev,re,r,rp)
	local turn_player=Duel.GetTurnPlayer()
	local sc=Duel.SelectReleaseGroup(turn_player,aux.FaceupFilter(Card.IsReleasableByEffect),1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	if Duel.Release(sc,REASON_EFFECT)>0 then
		local atk=sc:GetTextAttack()/2
		if atk>0 then
			Duel.Damage(1-turn_player,atk,REASON_EFFECT)
		end
	end
end