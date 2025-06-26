--共鳴する振動
--Harmonic Oscillation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_PZONE)==2 end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c)
	return not c:HasFlagEffect(id) or c:GetFlagEffectLabel(id)~=Duel.GetMatchingGroup(nil,c:GetControler(),LOCATION_PZONE,0,c):GetFirst():GetFlagEffectLabel(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_PZONE,2,nil) end
	Duel.SetTargetCard(Duel.GetFieldGroup(tp,0,LOCATION_PZONE))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg~=2 then return end
	local fid=e:GetFieldID()
	for pc in tg:Iter() do
		pc:ResetFlagEffect(id)
		pc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,1))
	end
	local left_scale_card=Duel.GetFieldCard(1-tp,LOCATION_PZONE,0)
	local right_scale_card=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	--While both targets are in their Pendulum Zones, you can Pendulum Summon using their Pendulum Scales this turn, but only from the Extra Deck
	local e1,e2=Pendulum.CreateHarmonicOscillationEffect(e:GetHandler(),nil,nil,nil,10000000)
	left_scale_card:RegisterEffect(e1)
	right_scale_card:RegisterEffect(e2)
end