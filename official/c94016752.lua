--深淵の宣告者
--Herald of the Abyss
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	--Make your opponent send a monster of the declared Type and Attribute they control to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end)
	e1:SetCost(Cost.PayLP(1500))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local race=Duel.AnnounceRace(tp,1,RACE_ALL)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local attr=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(race,attr)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.tgfilter(c,race,attr)
	return c:IsFaceup() and c:IsRace(race) and c:IsAttribute(attr) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local race,attr=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(1-tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,race,attr):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc,true)
	local code=sc:GetCode()
	if Duel.SendtoGrave(sc,REASON_RULE,PLAYER_NONE,1-tp)>0 then
		sc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
		--Cannot activate the monster effects of that monster or monsters with that name
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.aclimit)
		e1:SetLabel(code)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and (rc:HasFlagEffect(id) or rc:IsCode(e:GetLabel()))
end