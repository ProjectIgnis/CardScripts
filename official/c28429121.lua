--リチュアに伝わりし禁断の秘術
--Forbidden Arts of the Gishki
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Ritual.CreateProc(c,RITPROC_EQUAL,aux.FilterBoolFunction(Card.IsSetCard,0x3a),nil,nil,s.extrafil,s.extraop,aux.FilterBoolFunction(Card.IsOnField))
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
end
s.listed_series={0x3a}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.mfilter(c,e)
	return c:IsFaceup() and c:GetLevel()>0 and not c:IsImmuneToEffect(e) and c:IsReleasable()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroup(s.mfilter,tp,0,LOCATION_MZONE,nil,e)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,sc)
	Duel.ReleaseRitualMaterial(mat)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(sc:GetAttack()/2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	sc:RegisterEffect(e1)
end
