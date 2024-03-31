--貫通！
--Pierce!
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 monster be able to inflict piercing damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function() return Duel.IsAbleToEnterBP() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.CanGetPiercingRush),tp,LOCATION_MZONE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local tg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.CanGetPiercingRush),tp,LOCATION_MZONE,0,1,1,nil)
	if #tg>0 then
		Duel.HintSelection(tg,true)
		local tc=tg:GetFirst()
		--Inflict piercing damage
		tc:AddPiercing(RESETS_STANDARD_PHASE_END,e:GetHandler())
	end
end