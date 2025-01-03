--嫋々たる漣歌姫の壱世壊
--Tearlaments Perlegia
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(function(_,c) return c:IsSetCard(SET_TEARLAMENTS) or c:IsType(TYPE_FUSION) end)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--Send 1 Aqua monster from Deck to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.grcon)
	e3:SetTarget(s.grtg)
	e3:SetOperation(s.grop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_TEARLAMENTS}
function s.cfilter(c,tp)
	return c:IsRace(RACE_AQUA) and c:IsSetCard(SET_TEARLAMENTS) and c:IsControler(tp) and c:IsReason(REASON_EFFECT)
end
function s.grcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.grvfilter(c)
	return c:IsRace(RACE_AQUA) and c:IsLevelBelow(4) and c:IsAbleToGrave()
end
function s.grtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.grvfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.grop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.grvfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		if tc:IsLocation(LOCATION_GRAVE) and not tc:IsSetCard(SET_TEARLAMENTS) then
			--Cannot activate card or effects with the same name if it's not a "Tearlaments"
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end