local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.plasmacon)
	e1:SetTarget(s.sktg)
	e1:SetOperation(s.skop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.CheckLPCost(tp,1000) end
		Duel.PayLPCost(tp,1000)
	end)
	e2:SetOperation(function(e,tp) Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT) end)
	c:RegisterEffect(e2)
end

function s.plasmacon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,83965310),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end

function s.sktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=Duel.SelectOption(tp,
		aux.Stringid(id,0),
		aux.Stringid(id,1),
		aux.Stringid(id,2),
		aux.Stringid(id,3),
		aux.Stringid(id,4)
	)
	e:SetLabel(op)
end

function s.skop(e,tp)
	local handler=e:GetHandler()
	local phase_codes={PHASE_DRAW,PHASE_STANDBY,PHASE_MAIN1,PHASE_BATTLE,PHASE_END}
	local skip_codes={EFFECT_SKIP_DP,EFFECT_SKIP_SP,{EFFECT_SKIP_M1,EFFECT_SKIP_M2},EFFECT_SKIP_BP,EFFECT_SKIP_EP}
	local label=e:GetLabel()+1
	local ph=phase_codes[label]
	local skips=skip_codes[label]
	if not ph or not skips then return end
	if type(skips)~="table" then skips={skips} end

	local current_turn=Duel.GetTurnCount()

	for _,player in ipairs({tp,1-tp}) do
		for _,code in ipairs(skips) do
			local e1=Effect.CreateEffect(handler)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(code)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+ph+RESET_SELF_TURN,1)
			e1:SetCondition(function(eff) return Duel.GetTurnCount()>current_turn end)
			Duel.RegisterEffect(e1,player)
		end
	end
end

