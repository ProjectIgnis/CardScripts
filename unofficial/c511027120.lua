--爆走特急ロケット・アロー (Anime)
--Rocket Arrow Express (Anime)
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special Summon procedure: You can Special Summon this card while you control no cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Cannot attack the turn it is Special Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) end)
	c:RegisterEffect(e2)
	--You cannot Set or activate other cards while this card is on the field
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,2))
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3a:SetCode(EFFECT_CANNOT_MSET)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetTargetRange(1,0)
	e3a:SetTarget(aux.TRUE)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e3b)
	local e3c=e3a:Clone()
	e3c:SetCode(EFFECT_CANNOT_TURN_SET)
	c:RegisterEffect(e3c)
	local e3d=e3a:Clone()
	e3d:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3d:SetTarget(function(e,c,sump,sumtype,sumpos,targetp) return (sumpos&POS_FACEDOWN)>0 end)
	c:RegisterEffect(e3d)
	local e3e=e3a:Clone()
	e3e:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3e:SetValue(aux.TRUE)
	c:RegisterEffect(e3e)
	--Maintenance cost: Send 5 cards from  your hand to the GY during each of your Standby Phases
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e4:SetOperation(s.mtop)
	c:RegisterEffect(e4)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0,nil)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,nil)
	if #g>=5 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		if #g==5 then
			Duel.SendtoGrave(g,REASON_COST)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local hg=g:Select(tp,5,5,nil)
			Duel.SendtoGrave(hg,REASON_COST)
		end
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
