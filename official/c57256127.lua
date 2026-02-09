--JP name
--Shipping Archfiend
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You can target any number of face-up monsters on the field, and declare 1 Type or Attribute; they become that Type or Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.changetg)
	e1:SetOperation(s.changeop)
	c:RegisterEffect(e1)
	--If a monster(s) is Special Summoned to your opponent's field, while this card is in your Monster Zone (except during the Damage Step): You can target 1 monster on each field with the same Type and Attribute from each other; return them to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg) return not eg:IsContains(e:GetHandler()) and eg:IsExists(Card.IsControler,1,nil,1-tp) end)
	e2:SetTarget(s.rthtg)
	e2:SetOperation(s.rthop)
	c:RegisterEffect(e2)
end
function s.single_property_filter(c,func)
	local property=func(c)
	return property&(property-1)==0
end
function s.get_excluded_values(tg,func)
	return tg:Filter(s.single_property_filter,nil,func):GetBitwiseOr(func)
end
function s.changetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if not (chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()) then return false end
		local op,val=e:GetLabel()
		return (op==1 and chkc:IsRaceExcept(val)) or (op==2 and chkc:IsAttributeExcept(val))
	end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local max_target_count=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,max_target_count,nil)
	local excluded_races=s.get_excluded_values(tg,Card.GetRace)
	local excluded_attributes=s.get_excluded_values(tg,Card.GetAttribute)
	local b1=(excluded_races&RACE_ALL)~=RACE_ALL
	local b2=(excluded_attributes&ATTRIBUTE_ALL)~=ATTRIBUTE_ALL
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	local decl_race_attr=0
	if op==1 then
		decl_race_attr=Duel.AnnounceRace(tp,1,RACE_ALL&~excluded_races)
	elseif op==2 then
		decl_race_attr=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~excluded_attributes)
	end
	e:SetLabel(op,decl_race_attr)
end
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):Match(Card.IsFaceup,nil)
	if #tg==0 then return end
	local c=e:GetHandler()
	local op,decl_race_attr=e:GetLabel()
	local eff_code=op==1 and EFFECT_CHANGE_RACE or EFFECT_CHANGE_ATTRIBUTE
	for tc in tg:Iter() do
		--They become that Type or Attribute
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(eff_code)
		e1:SetValue(decl_race_attr)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.rescon(sg,e,tp,mg)
	return #sg==2 and sg:GetClassCount(Card.GetControler)==2
		and sg:GetClassCount(Card.GetRace)==1
		and sg:GetClassCount(Card.GetAttribute)==1
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetTargetGroup(aux.FaceupFilter(Card.IsAbleToHand),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_RTOHAND)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,2,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end