--Beware the Brothers Paradox!
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end 
s.listed_names={25833572,25955164,62340868,98434877}
function s.cfilter(c)
	return (c:IsCode(25833572) or c:IsCode(25955164) or c:IsCode(62340868) or c:IsCode(98434877)) and not c:IsPublic()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) and Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0 and Duel.GetFlagEffect(ep,id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--Reveal "Gate Guardian", "Kazejin", "Suijin", or "Sanga of the Thunder"
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,tc)
	--Activate
	Duel.Hint(HINT_SKILL_FLIP,tp,id|1<<32)
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	--OPD Register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Normal Summon Level 7 monsters for 1 less Tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetRange(0x5f)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLevel,7))
	e1:SetValue(0x1)
	Duel.RegisterEffect(e1,tp)
	--Tribute Summon 1 Level 7 monster in addition to Normal Summon/Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(0x5f)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLevel,7))
	Duel.RegisterEffect(e2,tp)
	--Opponent takes no effect damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(0x5f)
	e3:SetTargetRange(0,1)
	e3:SetValue(s.damval)
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	Duel.RegisterEffect(e4,tp)
	--Can only attack with 1 monster, but that monster can attack twice
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e5:SetRange(0x5f)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCondition(s.atkcon)
	e5:SetTarget(s.atktg)
	Duel.RegisterEffect(e5,tp)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_ATTACK_ANNOUNCE)
	e6:SetRange(0x5f)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(s.checkop)
	e6:SetLabelObject(e5)
	Duel.RegisterEffect(e6,tp)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e7:SetRange(0x5f)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetValue(1)
	e7:SetTarget(function(e,c) return c:GetAttackAnnouncedCount()>0 end)
	Duel.RegisterEffect(e7,tp)
end
--Damage Functions
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT~=0 then return 0 end
	return val
end
--Attack Functions
function s.atkcon(e)
	return e:GetHandler():GetFlagEffect(id+100)~=0
end
function s.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id+100)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	e:GetHandler():RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end