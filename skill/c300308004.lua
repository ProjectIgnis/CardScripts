--Major in Paleontology
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	--Flip this card over at the start of the Duel
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_FOSSIL}
s.listed_names={CARD_FOSSIL_FUSION}
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Banish 1 card from your hand face-down to place 1 Dig Counter on this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(0x5f)
	e1:SetCountLimit(1)
	e1:SetCondition(s.digctcon1)
	e1:SetOperation(s.digctop1)
	Duel.RegisterEffect(e1,tp)
	--Place 1 Dig Counter on this Skill if a "Fossil" Fusion monster is destroyed by card effect, or "
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(0x5f)
	e2:SetCondition(s.digctcon2)
	e2:SetOperation(s.digctop2)
	Duel.RegisterEffect(e2,tp)
	--Remove 1 Dig Counter to Fusion Summon 1 "Fossil" Fusion monster (this is treated as a Fusion Summon with "Fossil Fusion")
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_FOSSIL),matfilter=aux.FALSE,extrafil=s.fextra,
		extraop=Fusion.BanishMaterial,extratg=s.extratg,chkf=FUSPROC_NOLIMIT}
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(0x5f)
	e3:SetCountLimit(1)
	e3:SetCondition(function(_,tp) return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)>0 end)
	e3:SetTarget(Fusion.SummonEffTG(params))
	e3:SetOperation(Fusion.SummonEffOP(params))
	Duel.RegisterEffect(e3,tp)
	--Player Hint for Dig Counters
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCode(id+100)
	e4:SetTargetRange(1,0)
	Duel.RegisterEffect(e4,tp)
end
function s.digctcon1(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) and Duel.GetFlagEffect(tp,id)<1 
end

function s.digctop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_COST)>0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		--Effect to register hint for Dig Counter
		local ce=Duel.IsPlayerAffectedByEffect(tp,id+100)
		if ce then
			local nce=ce:Clone()
			ce:Reset()
			nce:SetDescription(aux.Stringid(id,4))
			Duel.RegisterEffect(nce,tp)
		end
	end
end
function s.fossilfilter(c,tp)
	return c:IsSetCard(SET_FOSSIL) and c:IsType(TYPE_FUSION) and c:IsFaceup() and c:IsReason(REASON_EFFECT)
end
function s.digctcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.fossilfilter,1,nil,tp) and Duel.GetFlagEffect(tp,id)<1 
end
function s.digctop2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) or Duel.GetFlagEffect(tp,id)>0 then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Effect to register hint for Dig Counter
	local ce=Duel.IsPlayerAffectedByEffect(tp,id+100)
	if ce then
		local nce=ce:Clone()
		ce:Reset()
		nce:SetDescription(aux.Stringid(id,4))
		Duel.RegisterEffect(nce,tp)
	end
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	else
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_ONFIELD,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(tp,id)>0 end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.ResetFlagEffect(tp,id)
	--Effect to register hint for Dig Counter
	local ce=Duel.IsPlayerAffectedByEffect(tp,id+100)
	if ce then
		local nce=ce:Clone()
		ce:Reset()
		nce:SetDescription(aux.Stringid(id,3))
		Duel.RegisterEffect(nce,tp)
	end
end