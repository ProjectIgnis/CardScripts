--ヴァリアブル・ステライザー
--Variable Stellarizer
--Scripted by YoshiDuels
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
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_GALAXY) and c:IsLevel(9) and c.material and not c:IsPublic()
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
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(code)
	e1:SetOperation(s.chngcon)
	c:RegisterEffect(e1)
end
function s.chngcon(scard,sumtype,tp)
	return Fusion.SummonEffect and Fusion.SummonEffect:GetHandler():IsCode(CARD_FUSION) and ((sumtype&MATERIAL_FUSION)~=0 or (sumtype&SUMMON_TYPE_FUSION)~=0)
end
