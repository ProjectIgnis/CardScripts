--幻壊兵ハケン・ハーケン
--Demolition Soldier Haken Haken
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send itself to GY, draw 2, then mill 2
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DECKDES)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(_,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)<=1 end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDraw(1-tp,2) and e:GetHandler():IsAbleToGrave() end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SendtoGrave(c,REASON_EFFECT)> 0 and Duel.Draw(tp,2,REASON_EFFECT)>0 and Duel.Draw(1-tp,2,REASON_EFFECT)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.sumlimit)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		--Can only Special Summon non-Wyrms in face-down Defense Position
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetTargetRange(1,0)
		e2:SetTarget(s.sumlimit)
		e2:SetValue(POS_FACEDOWN_DEFENSE)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetDescription(aux.Stringid(id,2))
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetCondition(s.atkcon)
		e3:SetTarget(s.atktg)
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,tp)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetCode(EVENT_ATTACK_ANNOUNCE)
		e4:SetOperation(s.checkop)
		e4:SetReset(RESET_PHASE|PHASE_END)
		e4:SetLabelObject(e3)
		Duel.RegisterEffect(e4,tp)
	end
end
function s.sumlimit(e,c)
	return not c:IsRace(RACE_WYRM)
end
function s.atkcon(e)
	return e:GetLabel()~=0
end
function s.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	e:GetLabelObject():SetLabel(fid)
end