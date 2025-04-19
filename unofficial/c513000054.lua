--クロス・ソウル (Anime)
--Soul Exchange (Anime)
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
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	for p=0,1 do
		local pfid=fid+p
		local g=Duel.GetFieldGroup(p,0,LOCATION_MZONE)
		if #g>0 then
			g:ForEach(function(c) c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,pfid) end)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_EXTRA_RELEASE)
			e1:SetTargetRange(0,LOCATION_MZONE)
			e1:SetTarget(function(_,c) return c:GetFlagEffectLabel(id)==pfid end)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,p)
		end
	end
end