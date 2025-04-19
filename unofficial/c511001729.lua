--リーゼント・ブリザードン
--Pompadour Blizzardon
local s,id=GetID()
function s.initial_effect(c)
	--Attack Position monsters cannot change their battle positions
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) end
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
        		e1:SetDescription(3313)
			e1:SetType(EFFECT_TYPE_SINGLE)
        		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
        		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        		tc:RegisterEffect(e1)
		end
	end
end