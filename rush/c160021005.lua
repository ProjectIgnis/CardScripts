--アクセルワンダー・ダーク
--Accel Wonder Dark
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change name
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.revealfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsDefense(2100) and c:IsType(TYPE_FUSION) and c.material and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleExtra(tp)
	--Effect
	local announceFilter={}
	for _,name in pairs(tc.material) do
		if #announceFilter==0 then
			table.insert(announceFilter,name)
			table.insert(announceFilter,OPCODE_ISCODE)
		else
			table.insert(announceFilter,name)
			table.insert(announceFilter,OPCODE_ISCODE)
			table.insert(announceFilter,OPCODE_OR)
		end
	end
	local code=Duel.AnnounceCard(tp,announceFilter)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(code)
	c:RegisterEffect(e1)
	--Prevent non-Spellcasters from attacking
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_OATH)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.ftarget)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.ftarget(e,c)
	return not c:IsRace(RACE_SPELLCASTER)
end