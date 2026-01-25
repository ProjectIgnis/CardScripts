--火麺味変化の術
--The Noodle Art of Flavor Modulation
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--This turn, the name of 1 face-up monster on your field becomes the name declared to meet the requirement
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--To check if you have not activated "The Noodle Art of Flavor Modulation" this turn
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={id}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(id) then
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.HasFlagEffect(tp,id)
end
function s.cfilter(c,...)
    if not (c:IsFaceup() and c:IsNotMaximumModeSide()) then return false end
    local named_mats={...}
    for key,current_mat in pairs(named_mats) do
        if not c:IsCode(current_mat) then
            return true
        end
    end
    return false
end
function s.revealfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAttack(2900) and not c:IsPublic()
		and c.material and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,table.unpack(c.material))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
end
function s.chkfilter(c,code)
	return c:IsFaceup() and not c:IsCode(code)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local fc=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,fc)
	Duel.ShuffleExtra(tp)
	--To populate the table with valid declarable names
	local announcement_filter={}
	for _,name in pairs(fc.material) do
		if Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE,0,1,nil,name) then
			if #announcement_filter==0 then
				table.insert(announcement_filter,name)
				table.insert(announcement_filter,OPCODE_ISCODE)
			else
				table.insert(announcement_filter,name)
				table.insert(announcement_filter,OPCODE_ISCODE)
				table.insert(announcement_filter,OPCODE_OR)
			end
		end
	end
	--Effect
	local declared_name=Duel.AnnounceCard(tp,announcement_filter)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,declared_name):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		--This turn, its name becomes the declared named
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(declared_name)
		tc:RegisterEffect(e1)
	end
end