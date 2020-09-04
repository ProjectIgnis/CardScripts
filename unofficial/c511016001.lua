--逆転する運命 (Anime)
--Reversal of Fate (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x5}
function s.filter(c)
	return c:IsSetCard(0x5) and c:GetFlagEffect(36690018)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g and #g>0 then
		for tc in aux.Next(g) do
			local val=tc:GetFlagEffectLabel(36690018)
			tc:SetFlagEffectLabel(36690018,1-val)
		end
	end
end
