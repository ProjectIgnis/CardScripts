--Rule of the day "Terradivide" v2 yup
--[[At the start of the duel each player places 1 Field Spell from their deck on the field (non turn player has their field face-down until the end phase),
Also Field spells cannot leave the field by card effects (only by activating another field spell),
And lastly cards that requires an empty field/no face-up cards had their effect modified to not count the Field Zone]]
local s,id=GetID()
function s.initial_effect(c)
    aux.GlobalCheck(s,function()
		--place field
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_STARTUP)
		e1:SetTarget(s.target)
		e1:SetOperation(s.activate)
		Duel.RegisterEffect(e1,0)
		local e2=e1:Clone()
		Duel.RegisterEffect(e2,1)
		--cannot leave the field or be affected
		local e3=Effect.CreateEffect(c)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_INDESTRUCTABLE)
		e3:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
		e3:SetValue(1)
		Duel.RegisterEffect(e3,0)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_REMOVE)
		Duel.RegisterEffect(e4,0)
		local e5=e3:Clone()
		e5:SetCode(EFFECT_CANNOT_TO_GRAVE)
		Duel.RegisterEffect(e5,0)
		local e6=e3:Clone()
		e6:SetCode(EFFECT_CANNOT_TO_HAND)
		Duel.RegisterEffect(e6,0)
		local e7=e3:Clone()
		e7:SetCode(EFFECT_CANNOT_TO_DECK)
		Duel.RegisterEffect(e7,0)
		local ea=e3:Clone()
		Duel.RegisterEffect(ea,1)
		local eb=e4:Clone()
		Duel.RegisterEffect(eb,1)
		local ec=e5:Clone()
		Duel.RegisterEffect(ec,1)
		local ed=e6:Clone()
		Duel.RegisterEffect(ed,1)
		local ee=e7:Clone()
		Duel.RegisterEffect(ee,1)

	end)
end
function s.filter(c,tp)
	return c:IsType(TYPE_FIELD) and (c:IsAbleToHand() or c:GetActivateEffect():IsActivatable(tp,true,true))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if Duel.IsTurnPlayer(tp) then
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	else
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEDOWN,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_FZONE,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_FZONE,0,nil)
	Duel.ChangePosition(g,POS_FACEUP)
end

--yes this is stupid (changing cards that requires empty field*)
--control no cards

--Gorz the Emissary of Darkness
if not c44330098 then
	c44330098 = {}
	setmetatable(c44330098, Card)
	rawset(c44330098,"__index",c44330098)
	function c44330098.initial_effect(c)
		--special summon
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(44330098,0))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		e1:SetRange(LOCATION_HAND)
		e1:SetCode(EVENT_DAMAGE)
		e1:SetCondition(c44330098.sumcon)
		e1:SetTarget(c44330098.sumtg)
		e1:SetOperation(c44330098.sumop)
		c:RegisterEffect(e1)
		--special summon success
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(44330098,1))
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCondition(c44330098.sumcon2)
		e2:SetTarget(c44330098.sumtg2)
		e2:SetOperation(c44330098.sumop2)
		e2:SetLabelObject(e1)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(44330098,2))
		e3:SetCategory(CATEGORY_DAMAGE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetCondition(c44330098.sumcon3)
		e3:SetTarget(c44330098.sumtg3)
		e3:SetOperation(c44330098.sumop3)
		e3:SetLabelObject(e1)
		c:RegisterEffect(e3)
	end
	c44330098.listed_names={44330099}
	function c44330098.filter(c)
		return not c:IsStatus(STATUS_LEAVE_CONFIRMED)
	end
	function c44330098.sumcon(e,tp,eg,ep,ev,re,r,rp)
		return ep==tp and tp~=rp and not Duel.IsExistingMatchingCard(c44330098.filter,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,nil)
	end
	function c44330098.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	end
	function c44330098.sumop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		local sumtype=1
		if (r&REASON_BATTLE)~=0 then sumtype=2 end
		if Duel.SpecialSummon(c,sumtype,tp,tp,false,false,POS_FACEUP)~=0 then
			e:SetLabel(ev)
		end
	end
	function c44330098.sumcon2(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+2
	end
	function c44330098.sumtg2(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	end
	function c44330098.sumop2(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local c=e:GetHandler()
		local val=e:GetLabelObject():GetLabel()
		if not Duel.IsPlayerCanSpecialSummonMonster(tp,44330098+1,0,TYPES_TOKEN,-2,-2,7,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
		local token=Duel.CreateToken(tp,44330098+1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(val)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e2)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
	function c44330098.sumcon3(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
	end
	function c44330098.sumtg3(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		local d=e:GetLabelObject():GetLabel()
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(d)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,d)
	end
	function c44330098.sumop3(e,tp,eg,ep,ev,re,r,rp)
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
--Hammer Bounzer
if not c44790889 then
	c44790889 = {}
	setmetatable(c44790889, Card)
	rawset(c44790889,"__index",c44790889)
	function c44790889.initial_effect(c)
		--summon with no tribute
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(44790889,0))
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(c44790889.ntcon)
		c:RegisterEffect(e1)
		--actlimit
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetCondition(c44790889.atkcon)
		e2:SetOperation(c44790889.atkop)
		c:RegisterEffect(e2)
	end
	function c44790889.ntcon(e,c,minc)
		if c==nil then return true end
		return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
			and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE|LOCATION_STZONE,0,nil)==0
			and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD,nil)>0
	end
	function c44790889.atkcon(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetAttackTarget()~=nil
			and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
	end
	function c44790889.atkop(e,tp,eg,ep,ev,re,r,rp)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(c44790889.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		Duel.RegisterEffect(e1,tp)
	end
	function c44790889.aclimit(e,re,tp)
		return re:IsHasType(EFFECT_TYPE_ACTIVATE)
	end
end
--Goddess of Sweet Revenge
if not c72589042 then
	c72589042 = {}
	setmetatable(c72589042, Card)
	rawset(c72589042,"__index",c72589042)
	function c72589042.initial_effect(c)
		--Destroy opponent's cards and Special summon from the Deck
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(72589042,0))
		e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetRange(LOCATION_HAND)
		e1:SetCondition(c72589042.condition)
		e1:SetCost(c72589042.cost)
		e1:SetTarget(c72589042.target)
		e1:SetOperation(c72589042.operation)
		c:RegisterEffect(e1)
	end
	function c72589042.condition(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetAttacker():IsControler(1-tp) and Duel.GetMatchingGroupCount(nil,tp,LOCATION_MZONE|LOCATION_STZONE+LOCATION_HAND,0,e:GetHandler())==0
	end
	function c72589042.cost(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return c:IsDiscardable() end
		Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	end
	function c72589042.target(e,tp,eg,ep,ev,re,r,rp,chk)
		local sg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		if chk==0 then return #sg>0 end
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
	function c72589042.filter(c,e,tp)
		return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	function c72589042.operation(e,tp,eg,ep,ev,re,r,rp)
		local sg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		if #sg>0 and Duel.Destroy(sg,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(c72589042.filter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(72589042,1)) then
			local tc=Duel.SelectMatchingCard(tp,c72589042.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
--D/D Pandora
if not c32146097 then
	c32146097 = {}
	setmetatable(c32146097, Card)
	rawset(c32146097,"__index",c32146097)
	function c32146097.initial_effect(c)
		--draw
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_DRAW)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_TO_GRAVE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCondition(c32146097.drcon)
		e1:SetTarget(c32146097.drtg)
		e1:SetOperation(c32146097.drop)
		c:RegisterEffect(e1)
	end
	function c32146097.drcon(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return (c:IsReason(REASON_BATTLE)
			or rp~=tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
			and Duel.GetFieldGroupCount(tp,LOCATION_MZONE|LOCATION_STZONE,0)==0
	end
	function c32146097.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
	function c32146097.drop(e,tp,eg,ep,ev,re,r,rp)
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
--Cockadoodledoo
if not c42338879 then
	c42338879 = {}
	setmetatable(c42338879, Card)
	rawset(c42338879,"__index",c42338879)
	function c42338879.initial_effect(c)
		--special summon
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_HAND)
		e1:SetCondition(c42338879.spcon)
		e1:SetOperation(c42338879.spop)
		c:RegisterEffect(e1)
		--redirect
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCondition(c42338879.recon)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2)
	end
	function c42338879.spcon(e,c)
		if c==nil then return true end
		local tp=c:GetControler()
		return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)==0
			or (Duel.GetFieldGroupCount(tp,LOCATION_MZONE|LOCATION_STZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0))
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	function c42338879.spop(e,tp,eg,ep,ev,re,r,rp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)==0 then
			e1:SetValue(3)
		else
			e1:SetValue(4)
		end
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
	function c42338879.recon(e)
		return e:GetHandler():IsFaceup()
	end
end
--Background Dragon
if not c42338879 then
	c42338879 = {}
	setmetatable(c42338879, Card)
	rawset(c42338879,"__index",c42338879)
	function c84976088.initial_effect(c)
		--Special summon itself (GY) and 1 level 4 or lower dragon monster (hand)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(42338879,0))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCountLimit(1,42338879)
		e1:SetCondition(c84976088.spcon)
		e1:SetTarget(c84976088.sptg)
		e1:SetOperation(c84976088.spop)
		c:RegisterEffect(e1)
	end
	function c84976088.spcon(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetFieldGroupCount(tp,LOCATION_MZONE|LOCATION_STZONE,0)==0
	end
	function c84976088.filter(c,e,tp)
		return c:IsLevelBelow(4) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	function c84976088.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(c84976088.filter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),2,tp,LOCATION_HAND+LOCATION_GRAVE)
	end
	function c84976088.spop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c84976088.filter,tp,LOCATION_HAND,0,1,1,c,e,tp)
		if #g>0 then
			g:AddCard(c)
			if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
				--Banish it if it leaves the field
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(3300)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
				e1:SetValue(LOCATION_REMOVED)
				c:RegisterEffect(e1,true)
			end		
		end
	end
end
--Chronomaly Moai Carrier
if not c38007744 then
	c38007744 = {}
	setmetatable(c38007744, Card)
	rawset(c38007744,"__index",c38007744)
	function c38007744.initial_effect(c)
		--special summon
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_HAND)
		e1:SetCondition(c38007744.spcon)
		c:RegisterEffect(e1)
	end
	function c38007744.spcon(e,c)
		if c==nil then return true end
		return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE|LOCATION_STZONE,0)==0
			and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE|LOCATION_STZONE)>0
			and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
	end	
end
--ZS – Ascend Sage
if not c4647954 then
	c4647954 = {}
	setmetatable(c4647954, Card)
	rawset(c4647954,"__index",c4647954)
	function c4647954.initial_effect(c)
		--Special summon itself from hand
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(4647954,0))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_HAND)
		e1:SetCondition(c4647954.spcon)
		c:RegisterEffect(e1)
		--Grant effect to "Utopia "Xyz monster using this card as material
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(4647954,1))
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BE_MATERIAL)
		e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
		e2:SetCountLimit(1,4647954)
		e2:SetCondition(c4647954.efcon)
		e2:SetOperation(c4647954.efop)
		c:RegisterEffect(e2)
	end
		--Lists "Utopia" and "Rank-Up-Magic" archetypes
	c4647954.listed_series={0x107f,0x95}
	
		--If you control no cards
	function c4647954.spcon(e,c)
		if c==nil then return true end
		return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
			Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE|LOCATION_STZONE,0)==0
	end
		--If an "Utopia" Xyz used this card as material
	function c4647954.efcon(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return r==REASON_XYZ and c:GetReasonCard():IsSetCard(0x107f)
	end
		--Grant effect to "Utopia "Xyz monster using this card as material
	function c4647954.efop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local rc=c:GetReasonCard()
		local e1=Effect.CreateEffect(rc)
		e1:SetDescription(aux.Stringid(4647954,2))
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetCondition(c4647954.xyzcon)
		e1:SetTarget(c4647954.xyztg)
		e1:SetOperation(c4647954.xyzop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1,true)
		if not rc:IsType(TYPE_EFFECT) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e2,true)
		end
	end
		--If Xyz summoned
	function c4647954.xyzcon(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
	end
		--Check for "Rank-Up-Magic" normal spell
	function c4647954.filter(c)
		return c:IsSetCard(0x95) and c:GetType()==TYPE_SPELL and c:IsAbleToHand()
	end
		--Activation legality
	function c4647954.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(c4647954.filter,tp,LOCATION_DECK,0,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
		--Add 1 "Rank-Up-Magic" normal spell from deck
	function c4647954.xyzop(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c4647954.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end	
end
--Blackwing - Gust the Backblast
if not c52869807 then
	c52869807 = {}
	setmetatable(c52869807, Card)
	rawset(c52869807,"__index",c52869807)
	function c52869807.initial_effect(c)
		--special summon
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_HAND)
		e1:SetCondition(c52869807.spcon)
		c:RegisterEffect(e1)
		--atk down
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetCondition(c52869807.atkcon)
		e2:SetTarget(c52869807.atktg)
		e2:SetValue(-300)
		c:RegisterEffect(e2)
	end
	c52869807.listed_series={0x33}
	function c52869807.spcon(e,c)
		if c==nil then return true end
		return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
			Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE|LOCATION_STZONE,0)==0
	end
	function c52869807.atkcon(e)
		local ph=Duel.GetCurrentPhase()
		local d=Duel.GetAttackTarget()
		local tp=e:GetHandlerPlayer()
		return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
			and d and d:IsControler(tp) and d:IsSetCard(0x33)
	end
	function c52869807.atktg(e,c)
		return c==Duel.GetAttacker()
	end
end
--Gnomaterial
if not c58655504 then
	c58655504 = {}
	setmetatable(c58655504, Card)
	rawset(c58655504,"__index",c58655504)
	function c58655504.initial_effect(c)
		--Limit material
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(58655504,0))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
		e1:SetRange(LOCATION_HAND)
		e1:SetCountLimit(1,58655504)
		e1:SetCondition(c58655504.condition)
		e1:SetCost(c58655504.cost)
		e1:SetTarget(c58655504.target)
		e1:SetOperation(c58655504.operation)
		c:RegisterEffect(e1)
	end
	function c58655504.condition(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE|LOCATION_STZONE,0)==0)
	end
	function c58655504.cost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsDiscardable() end
		Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	end
	function c58655504.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
		if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	end
	function c58655504.operation(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetDescription(aux.Stringid(58655504,1))
			e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e3:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
			tc:RegisterEffect(e3)
		end
	end
end
--Hi-Speedroid Kendama
if not c97007933 then
	c97007933 = {}
	setmetatable(c97007933, Card)
	rawset(c97007933,"__index",c97007933)
	function c97007933.initial_effect(c)
		--synchro summon
		Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
		c:EnableReviveLimit()
		--pierce
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		c:RegisterEffect(e1)
		--damage
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(97007933,0))
		e2:SetCategory(CATEGORY_DAMAGE)
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1,97007933)
		e2:SetCost(c97007933.damcost)
		e2:SetTarget(c97007933.damtg)
		e2:SetOperation(c97007933.damop)
		c:RegisterEffect(e2)
		--spsummon
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(97007933,1))
		e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_IGNITION)
		e3:SetRange(LOCATION_GRAVE)
		e3:SetCountLimit(1,{id,1})
		e3:SetCondition(c97007933.spcon)
		e3:SetCost(c97007933.spcost)
		e3:SetTarget(c97007933.sptg)
		e3:SetOperation(c97007933.spop)
		c:RegisterEffect(e3)
	end
	function c97007933.cfilter(c)
		return c:IsRace(RACE_MACHINE) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
	end
	function c97007933.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(c97007933.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c97007933.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
	function c97007933.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(500)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	end
	function c97007933.damop(e,tp,eg,ep,ev,re,r,rp)
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	end
	function c97007933.spcon(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetFieldGroupCount(tp,LOCATION_MZONE|LOCATION_STZONE,0)==0
	end
	function c97007933.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_MSET)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e3:SetDescription(aux.Stringid(97007933,2))
		e3:SetReset(RESET_PHASE+PHASE_END)
		e3:SetTargetRange(1,0)
		Duel.RegisterEffect(e3,tp)
	end
	function c97007933.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	end
	function c97007933.spop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end	
end
--Symbol of Friendship
if not c2295831 then
	c2295831 = {}
	setmetatable(c2295831, Card)
	rawset(c2295831,"__index",c2295831)
	function c2295831.initial_effect(c)
		--Activate
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DRAW)
		e1:SetCondition(c2295831.regcon)
		e1:SetOperation(c2295831.regop)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e2:SetType(EFFECT_TYPE_ACTIVATE)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetCondition(c2295831.condition)
		e2:SetCost(c2295831.cost)
		e2:SetTarget(c2295831.target)
		e2:SetOperation(c2295831.activate)
		c:RegisterEffect(e2)
	end
	function c2295831.regcon(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return Duel.GetFieldGroupCount(tp,LOCATION_MZONE|LOCATION_STZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=3
			and Duel.GetCurrentPhase()==PHASE_DRAW and c:IsReason(REASON_RULE)
	end
	function c2295831.regop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if Duel.SelectYesNo(tp,aux.Stringid(2295831,0)) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_PUBLIC)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
			c:RegisterEffect(e1)
			c:RegisterFlagEffect(2295831,RESET_PHASE+PHASE_MAIN1,EFFECT_FLAG_CLIENT_HINT,1,0,66)
		end
	end
	function c2295831.condition(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetCurrentPhase()==PHASE_MAIN1
	end
	function c2295831.cost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():GetFlagEffect(2295831)~=0 end
	end
	function c2295831.target(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	function c2295831.activate(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
--Infinite Impermanence
if not c10045474 then
	c10045474 = {}
	setmetatable(c10045474, Card)
	rawset(c10045474,"__index",c10045474)
	function c10045474.initial_effect(c)
		--Negate the effects of 1 monster the opponent controls
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_DISABLE)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
		e1:SetTarget(c10045474.target)
		e1:SetOperation(c10045474.activate)
		c:RegisterEffect(e1)
		--Can be activated from the hand
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(10045474,0))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
		e2:SetCondition(c10045474.handcon)
		c:RegisterEffect(e2)
	end
	function c10045474.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsNegatableMonster() end
		if chk==0 then return Duel.IsExistingTarget(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,nil) end
		local c=e:GetHandler()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectTarget(tp,Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
		local pos=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsStatus(STATUS_ACT_FROM_HAND) and c:IsPreviousPosition(POS_FACEDOWN) and POS_FACEDOWN or 0
		Duel.SetTargetParam(pos)
	end
	function c10045474.activate(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			--Negate its effects
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e2)
			local pos=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
			if c:IsRelateToEffect(e) and pos&POS_FACEDOWN>0 then
				Duel.BreakEffect()
				c:RegisterFlagEffect(10045474,RESET_CHAIN,0,0)
				--Negate Spell/Trap effects in the same column
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_FIELD)
				e3:SetCode(EFFECT_DISABLE)
				e3:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
				e3:SetTarget(c10045474.distg)
				e3:SetReset(RESET_PHASE|PHASE_END)
				e3:SetLabel(c:GetSequence())
				Duel.RegisterEffect(e3,tp)
				local e4=e3:Clone()
				e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				Duel.RegisterEffect(e4,tp)
				local e5=Effect.CreateEffect(c)
				e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e5:SetCode(EVENT_CHAIN_SOLVING)
				e5:SetOperation(c10045474.disop)
				e5:SetReset(RESET_PHASE|PHASE_END)
				e5:SetLabel(c:GetSequence())
				Duel.RegisterEffect(e5,tp)
				local zone=1<<(c:GetSequence()+8)
				Duel.Hint(HINT_ZONE,tp,zone)
			end
		end
	end
	function c10045474.distg(e,c)
		local seq=e:GetLabel()
		if c:IsControler(1-e:GetHandlerPlayer()) then seq=4-seq end
		return c:IsSpellTrap() and seq==c:GetSequence() and c:GetFlagEffect(10045474)==0
	end
	function c10045474.disop(e,tp,eg,ep,ev,re,r,rp)
		local cseq=e:GetLabel()
		if not re:IsSpellTrapEffect() then return end
		local rc=re:GetHandler()
		if rc:HasFlagEffect(10045474) then return end
		local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
		if re:IsHasType(EFFECT_TYPE_ACTIVATE) then
			if loc&LOCATION_SZONE==0 or rc:IsControler(1-p) then
				if rc:IsLocation(LOCATION_SZONE) and rc:IsControler(p) then
					seq=rc:GetSequence()
				else
					seq=rc:GetPreviousSequence()
				end
			end
			if loc&LOCATION_SZONE==0 then
				local val=re:GetValue()
				if val==nil or val==LOCATION_SZONE or val==LOCATION_FZONE or val==LOCATION_PZONE then
					loc=LOCATION_SZONE
				end
			end
		end
		if ep~=e:GetHandlerPlayer() then cseq=4-cseq end
		if loc&LOCATION_SZONE~=0 and cseq==seq then
			Duel.NegateEffect(ev)
		end
	end
	function c10045474.handcon(e)
		return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_STZONE,0)==0
	end
end
--Evenly Matched
if not c15693423 then
	c15693423 = {}
	setmetatable(c15693423, Card)
	rawset(c15693423,"__index",c15693423)
	function c15693423.initial_effect(c)
		--Make the opponent banish cards they control
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(15693423,1))
		e1:SetCategory(CATEGORY_REMOVE)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetHintTiming(TIMING_BATTLE_END)
		e1:SetCondition(function() return Duel.GetCurrentPhase()==PHASE_BATTLE end)
		e1:SetTarget(c15693423.target)
		e1:SetOperation(c15693423.activate)
		c:RegisterEffect(e1)
		--Can be activated from the hand
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(15693423,0))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
		e2:SetCondition(c15693423.handcon)
		c:RegisterEffect(e2)
	end
	function c15693423.rmfilter(c,p)
		return Duel.IsPlayerCanRemove(p,c) and not c:IsType(TYPE_TOKEN)
	end
	function c15693423.target(e,tp,eg,ep,ev,re,r,rp,chk)
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		local ct=#g-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
		if e:GetHandler():IsLocation(LOCATION_HAND) then ct=ct-1 end
		if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,30459350)
			and ct>0 and g:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE) end
		--Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
	end
	function c15693423.activate(e,tp,eg,ep,ev,re,r,rp)
		if Duel.IsPlayerAffectedByEffect(1-tp,30459350) then return end
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		local ct=#g-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
		if ct>0 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
			local sg=g:FilterSelect(1-tp,Card.IsAbleToRemove,ct,ct,nil,1-tp,POS_FACEDOWN,REASON_RULE)
			Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,1-tp)
		end
	end
	function c15693423.handcon(e)
		return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_STZONE,0)==0
			and Duel.GetFieldGroupCount(1-e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_STZONE,0)>1
	end
end
--The Phantom Knights of Dark Gauntlets
if not c24212820 then
	c24212820 = {}
	setmetatable(c24212820, Card)
	rawset(c24212820,"__index",c24212820)
	function c24212820.initial_effect(c)
		--Send 1 "Phantom Knights" spell/trap from deck to GY
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_TOGRAVE)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetTarget(c24212820.target)
		e1:SetOperation(c24212820.activate)
		e1:SetHintTiming(0,TIMING_END_PHASE)
		c:RegisterEffect(e1)
		--Special summon itself from GY as a monster
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(24212820,0))
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetCondition(c24212820.spcon)
		e2:SetTarget(c24212820.sptg)
		e2:SetOperation(c24212820.spop)
		c:RegisterEffect(e2)
		--Gains 300 DEF for each "Phantom Knights" spell/trap in your GY
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		e3:SetCondition(c24212820.defcon)
		e3:SetValue(c24212820.defval)
		c:RegisterEffect(e3)
	end
	c24212820.listed_series={0xdb}
	
	function c24212820.tgfilter(c)
		return c:IsSetCard(0xdb) and c:IsSpellTrap() and c:IsAbleToGrave()
	end
	function c24212820.target(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(c24212820.tgfilter,tp,LOCATION_DECK,0,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
	function c24212820.activate(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,c24212820.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	function c24212820.spcon(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetFieldGroupCount(tp,LOCATION_MZONE|LOCATION_STZONE,0)==0
			and Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
	end
	function c24212820.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,24212820,0x10db,0x21,300,600,4,RACE_WARRIOR,ATTRIBUTE_DARK) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	end
	function c24212820.spop(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,24212820,0x10db,0x21,300,600,4,RACE_WARRIOR,ATTRIBUTE_DARK) then
			c:AddMonsterAttribute(TYPE_EFFECT)
			c:AssumeProperty(ASSUME_RACE,RACE_WARRIOR)
			Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP_DEFENSE)
			c:AddMonsterAttributeComplete()
			--Banish it if it leaves the field
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3300)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
			Duel.SpecialSummonComplete()
		end
	end
	function c24212820.defcon(e)
		return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
	end
	function c24212820.filter(c)
		return c:IsSetCard(0xdb) and c:IsSpellTrap()
	end
	function c24212820.defval(e,c)
		return Duel.GetMatchingGroupCount(c24212820.filter,c:GetControler(),LOCATION_GRAVE,0,nil)*300
	end
end
--NEXT
if not c74414885 then
	c74414885 = {}
	setmetatable(c74414885, Card)
	rawset(c74414885,"__index",c74414885)
	function c74414885.initial_effect(c)
		--Activate
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1,74414885,EFFECT_COUNT_CODE_OATH)
		e1:SetTarget(c74414885.sptg)
		e1:SetOperation(c74414885.spop)
		c:RegisterEffect(e1)
		--Can be activated from the hand
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(74414885,0))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
		e2:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_STZONE,0)==0 end)
		c:RegisterEffect(e2)
	end
	c74414885.listed_series={SET_NEO_SPACIAN}
	c74414885.listed_names={CARD_NEOS}
	function c74414885.filter(c,e,tp)
		return (c:IsSetCard(SET_NEO_SPACIAN) or c:IsCode(CARD_NEOS)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	function c74414885.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(c74414885.filter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	end
	function c74414885.spop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if ft>5 then ft=5 end
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c74414885.filter),tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp)
		local g=aux.SelectUnselectGroup(sg,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
		if #g>0 then
			for tc in g:Iter() do
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1,true)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e2,true)
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_FIELD)
				e3:SetRange(LOCATION_MZONE)
				e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e3:SetAbsoluteRange(tp,1,0)
				e3:SetTarget(c74414885.splimit)
				e3:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e3,true)
				--Lizard check
				local e4=aux.createContinuousLizardCheck(c,LOCATION_MZONE,c74414885.lizfilter)
				e4:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e4,true)
			end
		end
	end
	function c74414885.splimit(e,c)
		return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
	end
	function c74414885.lizfilter(e,c)
		return not c:IsOriginalType(TYPE_FUSION)
	end
end

--control no face up cards

--Machina Metalcrunch
if not c69838761 then
	c69838761 = {}
	setmetatable(c69838761, Card)
	rawset(c69838761,"__index",c69838761)
	function c69838761.initial_effect(c)
		--normal summon
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(69838761,0))
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(c69838761.ntcon)
		e1:SetOperation(c69838761.ntop)
		c:RegisterEffect(e1)
		--to hand
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(69838761,1))
		e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
		e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		e2:SetCountLimit(1,69838761)
		e2:SetTarget(c69838761.thtg)
		e2:SetOperation(c69838761.thop)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(e3)
	end
	function c69838761.ntcon(e,c,minc)
		if c==nil then return true end
		return minc==0 and c:IsLevelAbove(5) and not Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_STZONE,0,1,nil)
	end
	function c69838761.ntop(e,tp,eg,ep,ev,re,r,rp,c)
		--change base attack
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(1800)
		c:RegisterEffect(e1)
	end
	function c69838761.thfilter(c)
		return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
	end
	function c69838761.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(c69838761.thfilter,tp,LOCATION_DECK,0,3,nil) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	function c69838761.thop(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(c69838761.thfilter,tp,LOCATION_DECK,0,nil)
		if #g>=3 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,3,3,nil)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleDeck(tp)
			local tg=sg:RandomSelect(1-tp,1)
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	end	
end
-- Lightning Storm
if not c14532163 then
	c14532163 = {}
	setmetatable(c14532163, Card)
	rawset(c14532163,"__index",c14532163)
	function c14532163.initial_effect(c)
		-- Destroy
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1,14532163,EFFECT_COUNT_CODE_OATH)
		e1:SetCondition(c14532163.descon)
		e1:SetTarget(c14532163.destg)
		e1:SetOperation(c14532163.desop)
		c:RegisterEffect(e1)
	end
	function c14532163.descon(e,tp,eg,ep,ev,re,r,rp)
		return not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,nil)
	end
	function c14532163.destg(e,tp,eg,ep,ev,re,r,rp,chk)
		local g1=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
		local g2=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
		local b1=#g1>0
		local b2=#g2>0
		if chk==0 then return b1 or b2 end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(14532163,0)},
			{b2,aux.Stringid(14532163,1)})
		e:SetLabel(op)
		local g=(op==1 and g1 or g2)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	end
	function c14532163.desop(e,tp,eg,ep,ev,re,r,rp)
		if e:GetLabel()==1 then
			local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
			if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
		else
			local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
			if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
		end
	end
end
--control no S/T (skipped BA) (control no spell) for search

--The despair URANUS
if not c32588805 then
	c32588805 = {}
	setmetatable(c32588805, Card)
	rawset(c32588805,"__index",c32588805)
	function c32588805.initial_effect(c)
		--set
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(32588805,0))
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetCondition(c32588805.setcon)
		e1:SetTarget(c32588805.settg)
		e1:SetOperation(c32588805.setop)
		c:RegisterEffect(e1)
		--atkup
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(c32588805.atkval)
		c:RegisterEffect(e2)
		--indes
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(LOCATION_SZONE,0)
		e3:SetTarget(c32588805.indtg)
		e3:SetValue(1)
		c:RegisterEffect(e3)
	end
	function c32588805.setcon(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
			and not Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,nil)
	end
	function c32588805.setfilter1(c)
		return c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
	end
	function c32588805.settg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(c32588805.setfilter1,tp,LOCATION_DECK,0,1,nil) end
	end
	function c32588805.setfilter2(c,typ)
		return c:GetType()==typ and c:IsSSetable()
	end
	function c32588805.setop(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_OPTION)
		local op=Duel.SelectOption(1-tp,71,72)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=nil
		if op==0 then g=Duel.SelectMatchingCard(tp,c32588805.setfilter2,tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL+TYPE_CONTINUOUS)
		else g=Duel.SelectMatchingCard(tp,c32588805.setfilter2,tp,LOCATION_DECK,0,1,1,nil,TYPE_TRAP+TYPE_CONTINUOUS) end
		if #g>0 then
			Duel.SSet(tp,g:GetFirst())
		end
	end
	function c32588805.atkfilter(c)
		return c:IsSpellTrap() and c:IsFaceup()
	end
	function c32588805.atkval(e,c)
		return Duel.GetMatchingGroupCount(c32588805.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*300
	end
	function c32588805.indtg(e,c)
		return c:GetSequence()<5 and c:IsFaceup()
	end
end
--Naturia Pinapple
if not c7304544 then
	c7304544 = {}
	setmetatable(c7304544, Card)
	rawset(c7304544,"__index",c7304544)
	function c7304544.initial_effect(c)
		--Change race
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(RACE_PLANT)
		c:RegisterEffect(e1)
		--Special Summon
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(7304544,0))
		e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetCountLimit(1)
		e2:SetCondition(c7304544.condition)
		e2:SetTarget(c7304544.target)
		e2:SetOperation(c7304544.operation)
		c:RegisterEffect(e2)
	end
	function c7304544.filter(c)
		return c:IsType(TYPE_SPELL+TYPE_TRAP) or (c:IsCode(7304544) and c:IsFaceup())
	end
	function c7304544.filter2(c)
		return c:IsMonster() and not c:IsRace(RACE_PLANT+RACE_BEAST)
	end
	function c7304544.condition(e,tp,eg,ep,ev,re,r,rp)
		return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(c7304544.filter,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,nil) 
			and not Duel.IsExistingMatchingCard(c7304544.filter2,tp,LOCATION_GRAVE,0,1,nil)
	end
	function c7304544.target(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	end
	function c7304544.operation(e,tp,eg,ep,ev,re,r,rp)
		if e:GetHandler():IsRelateToEffect(e)
			and not Duel.IsExistingMatchingCard(c7304544.filter,tp,LOCATION_ONFIELD,0,1,nil)
			and not Duel.IsExistingMatchingCard(c7304544.filter2,tp,LOCATION_GRAVE,0,1,nil) then
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
--Steelswarm Scout
if not c90727556 then
	c90727556 = {}
	setmetatable(c90727556, Card)
	rawset(c90727556,"__index",c90727556)
	function c90727556.initial_effect(c)
		--Special Summon
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(90727556,0))
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCondition(c90727556.condition)
		e1:SetCost(c90727556.cost)
		e1:SetTarget(c90727556.target)
		e1:SetOperation(c90727556.operation)
		c:RegisterEffect(e1)
		--cannot release
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		e2:SetValue(1)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UNRELEASABLE_SUM)
		e3:SetValue(c90727556.sumlimit)
		c:RegisterEffect(e3)
		--cannot be synchro material
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e4:SetValue(1)
		c:RegisterEffect(e4)
	end
	c90727556.listed_series={0x100a}
	function c90727556.condition(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity() and e:GetHandler():IsSetCard(0x100a)
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
	end
	function c90727556.cost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetLabelObject(e)
		e1:SetTarget(c90727556.splimit)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(90727556,1))
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTargetRange(1,0)
		Duel.RegisterEffect(e2,tp)
	end
	function c90727556.splimit(e,c,sump,sumtype,sumpos,targetp,se)
		return e:GetLabelObject()~=se
	end
	function c90727556.target(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	end
	function c90727556.operation(e,tp,eg,ep,ev,re,r,rp)
		if e:GetHandler():IsRelateToEffect(e) then
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
	function c90727556.sumlimit(e,c)
		return not c:IsSetCard(0x100a)
	end
end
--Treeborn Frog
if not c12538374 then
	c12538374 = {}
	setmetatable(c12538374, Card)
	rawset(c12538374,"__index",c12538374)
	function c12538374.initial_effect(c)
		--Special Summon
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(12538374,0))
		e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCountLimit(1)
		e1:SetCondition(c12538374.condition)
		e1:SetTarget(c12538374.target)
		e1:SetOperation(c12538374.operation)
		c:RegisterEffect(e1)
	end
	c12538374.listed_names={id}
	function c12538374.filter(c)
		return c:IsSpellTrap() or (c:IsCode(12538374) and c:IsFaceup())
	end
	function c12538374.condition(e,tp,eg,ep,ev,re,r,rp)
		return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(c12538374.filter,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,nil) 
	end
	function c12538374.target(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	end
	function c12538374.operation(e,tp,eg,ep,ev,re,r,rp)
		if e:GetHandler():IsRelateToEffect(e) and not Duel.IsExistingMatchingCard(c12538374.filter,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,nil) then
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
--Samsara Lotus
if not c5592689 then
	c5592689 = {}
	setmetatable(c5592689, Card)
	rawset(c5592689,"__index",c5592689)
	function c5592689.initial_effect(c)
		--Special Summon
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(5592689,0))
		e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCountLimit(1)
		e1:SetCondition(c5592689.sscon)
		e1:SetTarget(c5592689.sstg)
		e1:SetOperation(c5592689.ssop)
		c:RegisterEffect(e1)
		--damage
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(5592689,1))
		e2:SetCategory(CATEGORY_DAMAGE)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCondition(c5592689.dmcon)
		e2:SetTarget(c5592689.dmtg)
		e2:SetOperation(c5592689.dmop)
		c:RegisterEffect(e2)
	end
	function c5592689.filter(c)
		return c:IsType(TYPE_SPELL+TYPE_TRAP)
	end
	function c5592689.sscon(e,tp,eg,ep,ev,re,r,rp)
		return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(c5592689.filter,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,nil) 
	end
	function c5592689.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	end
	function c5592689.ssop(e,tp,eg,ep,ev,re,r,rp)
		if e:GetHandler():IsRelateToEffect(e) and not Duel.IsExistingMatchingCard(c5592689.filter,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,nil) then
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
	end
	function c5592689.dmcon(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetTurnPlayer()==tp
	end
	function c5592689.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(1000)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
	end
	function c5592689.dmop(e,tp,eg,ep,ev,re,r,rp)
		if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
--Typhoon
if not c14883228 then
	c14883228 = {}
	setmetatable(c14883228, Card)
	rawset(c14883228,"__index",c14883228)
	function c14883228.initial_effect(c)
		--Activate
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetHintTiming(0,TIMING_END_PHASE)
		e1:SetTarget(c14883228.target)
		e1:SetOperation(c14883228.activate)
		c:RegisterEffect(e1)
		--act in hand
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
		e2:SetDescription(aux.Stringid(14883228,0))
		e2:SetCondition(c14883228.handcon)
		c:RegisterEffect(e2)
	end
	function c14883228.handcon(e)
		local tp=e:GetHandlerPlayer()
		return not Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,2,nil)
	end
	function c14883228.filter(c)
		return c:IsFaceup() and c:IsSpellTrap()
	end
	function c14883228.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsOnField() and c14883228.filter(chkc) and chkc~=e:GetHandler() end
		if chk==0 then return Duel.IsExistingTarget(c14883228.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,c14883228.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
	function c14883228.activate(e,tp,eg,ep,ev,re,r,rp)
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
--control no other cards

--Witch of the Black Rose
if not c17720747 then
	c17720747 = {}
	setmetatable(c17720747, Card)
	rawset(c17720747,"__index",c17720747)
	function c17720747.initial_effect(c)
		--cannot special summon
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SPSUMMON_CONDITION)
		c:RegisterEffect(e1)
		--Draw
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(17720747,0))
		e2:SetCategory(CATEGORY_DRAW)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		e2:SetCondition(c17720747.condition)
		e2:SetTarget(c17720747.target)
		e2:SetOperation(c17720747.operation)
		c:RegisterEffect(e2)
	end
	function c17720747.condition(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetFieldGroupCount(tp,LOCATION_MZONE|LOCATION_STZONE,0)<=1
	end
	function c17720747.target(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	function c17720747.operation(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		Duel.Draw(tp,1,REASON_EFFECT)
		if tc then
			Duel.ConfirmCards(1-tp,tc)
			if not tc:IsMonster() then
				Duel.BreakEffect()
				Duel.SendtoGrave(tc,REASON_EFFECT)
				if e:GetHandler():IsRelateToEffect(e) then
					Duel.Destroy(e:GetHandler(),REASON_EFFECT)
				end
			end
			Duel.ShuffleHand(tp)
		end
	end
end
--Elemental Hero Bubbleman
if not c79979666 then
	c79979666 = {}
	setmetatable(c79979666, Card)
	rawset(c79979666,"__index",c79979666)
	function c79979666.initial_effect(c)
		--special summon
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_HAND)
		e1:SetCondition(c79979666.spcon)
		c:RegisterEffect(e1)
		--draw
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(79979666,1))
		e2:SetCategory(CATEGORY_DRAW)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP)
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		e2:SetCondition(c79979666.condition)
		e2:SetTarget(c79979666.target)
		e2:SetOperation(c79979666.operation)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(e3)
		local e4=e2:Clone()
		e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		c:RegisterEffect(e4)
	end
	function c79979666.spcon(e,c)
		if c==nil then return true end
		return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)==1
			and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
	end
	function c79979666.filter(c)
		return not c:IsStatus(STATUS_LEAVE_CONFIRMED) and not c:IsLocation(LOCATION_FZONE)
	end
	function c79979666.condition(e,tp,eg,ep,ev,re,r,rp)
		return not Duel.IsExistingMatchingCard(c79979666.filter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler())
	end
	function c79979666.target(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
	function c79979666.operation(e,tp,eg,ep,ev,re,r,rp)
		if Duel.IsExistingMatchingCard(c79979666.filter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler()) then return end
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
--Valkyrie of the Nordic Ascendant
if not c40844552 then
	c40844552 = {}
	setmetatable(c40844552, Card)
	rawset(c40844552,"__index",c40844552)
	function c40844552.initial_effect(c)
		--token
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(40844552,0))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetCondition(c40844552.condition)
		e1:SetCost(c40844552.cost)
		e1:SetTarget(c40844552.target)
		e1:SetOperation(c40844552.operation)
		c:RegisterEffect(e1)
	end
	c40844552.listed_names={40844553}
	c40844552.listed_series={0x42}
	function c40844552.condition(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE|LOCATION_STZONE,0)<=1
	end
	function c40844552.cfilter(c)
		return c:IsSetCard(0x42) and c:IsMonster() and c:IsAbleToRemoveAsCost()
	end
	function c40844552.cost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(c40844552.cfilter,tp,LOCATION_HAND,0,2,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c40844552.cfilter,tp,LOCATION_HAND,0,2,2,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
	function c40844552.target(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsPlayerCanSpecialSummonMonster(tp,40844552+1,0,TYPES_TOKEN,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_EARTH) end
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
	end
	function c40844552.operation(e,tp,eg,ep,ev,re,r,rp)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2
			or not Duel.IsPlayerCanSpecialSummonMonster(tp,40844552+1,0,TYPES_TOKEN,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_EARTH) then return end
		for i=1,2 do
			local token=Duel.CreateToken(tp,40844552+1)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
		Duel.SpecialSummonComplete()
	end
end
--Number 59: Crooked Cook
if not c82697249 then
	c82697249 = {}
	setmetatable(c82697249, Card)
	rawset(c82697249,"__index",c82697249)
	function c82697249.initial_effect(c)
		--xyz summon
		Xyz.AddProcedure(c,nil,4,2)
		c:EnableReviveLimit()
		--immune
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(c82697249.imcon)
		e1:SetValue(c82697249.efilter)
		c:RegisterEffect(e1)
		--destroy
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(82697249,0))
		e2:SetCategory(CATEGORY_DESTROY)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetCountLimit(1)
		e2:SetCost(c82697249.descost)
		e2:SetTarget(c82697249.destg)
		e2:SetOperation(c82697249.desop)
		c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	end
	c82697249.xyz_number=59
	function c82697249.imcon(e)
		return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_STZONE,0)==1
	end
	function c82697249.efilter(e,te)
		return te:GetOwner()~=e:GetOwner()
	end
	function c82697249.descost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	end
	function c82697249.destg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	end
	function c82697249.ctfilter(c)
		return c:IsLocation(LOCATION_GRAVE) and c:IsMonster()
	end
	function c82697249.desop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,c)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			local ct=Duel.GetOperatedGroup():FilterCount(c82697249.ctfilter,nil)
			if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
				Duel.BreakEffect()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
				e1:SetValue(ct*300)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e1)
			end
		end
	end
end
--Bujinunity
if not c33611061 then
	c33611061 = {}
	setmetatable(c33611061, Card)
	rawset(c33611061,"__index",c33611061)
	function c33611061.initial_effect(c)
		--activate
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_TODECK+CATEGORY_HANDES+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1,33611061,EFFECT_COUNT_CODE_OATH)
		e1:SetCondition(c33611061.condition)
		e1:SetTarget(c33611061.target)
		e1:SetOperation(c33611061.activate)
		c:RegisterEffect(e1)
	end
	c33611061.listed_series={0x88}
	function c33611061.condition(e,tp,eg,ep,ev,re,r,rp)
		return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,e:GetHandler())
	end
	function c33611061.filter(c)
		return c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR) and c:IsAbleToDeck()
	end
	function c33611061.target(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(c33611061.filter,tp,LOCATION_GRAVE,0,1,nil) end
		local g=Duel.GetMatchingGroup(c33611061.filter,tp,LOCATION_GRAVE,0,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	function c33611061.thfilter(c)
		return c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR) and c:IsAbleToHand()
	end
	function c33611061.activate(e,tp,eg,ep,ev,re,r,rp)
		local tg=Duel.GetMatchingGroup(c33611061.filter,tp,LOCATION_GRAVE,0,nil)
		if #tg>0 then
			Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
			Duel.SendtoGrave(hg,REASON_EFFECT)
			Duel.BreakEffect()
			local g=Duel.GetMatchingGroup(c33611061.thfilter,tp,LOCATION_DECK,0,nil)
			if #g==0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g1=g:Select(tp,1,1,nil)
			g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(33611061,0)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g2=g:Select(tp,1,1,nil)
				g:Remove(Card.IsCode,nil,g2:GetFirst():GetCode())
				g1:Merge(g2)
				if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(33611061,0)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
					local g3=g:Select(tp,1,1,nil)
					g1:Merge(g3)
				end
			end
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g1)
		end
	end
end
--On Your Mark, Get Set, DUEL!
if not c31006879 then
	c31006879 = {}
	setmetatable(c31006879, Card)
	rawset(c31006879,"__index",c31006879)
	function c31006879.initial_effect(c)
		--Search 1 "Synchron" on activation
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1,31006879,EFFECT_COUNT_CODE_OATH)
		e1:SetOperation(c31006879.activate)
		c:RegisterEffect(e1)
		--Place 1 Signal Counter on this card
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(31006879,1))
		e2:SetCategory(CATEGORY_COUNTER)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCountLimit(1)
		e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
		e2:SetOperation(c31006879.ctop)
		c:RegisterEffect(e2)
		--Draw 2 then send 1 to the GY ("Speed Spell - Angel Baton")
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(31006879,2))
		e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
		e3:SetType(EFFECT_TYPE_IGNITION)
		e3:SetRange(LOCATION_SZONE)
		e3:SetCost(c31006879.drcost)
		e3:SetTarget(c31006879.drtg)
		e3:SetOperation(c31006879.drop)
		c:RegisterEffect(e3)
	end
	c31006879.listed_series={0x1017}
	c31006879.counter_list={0x1148}
	function c31006879.filter(c,e,tp)
		return c:IsSetCard(0x1017) and c:IsMonster() and c:IsAbleToHand()
	end
	function c31006879.activate(e,tp,eg,ep,ev,re,r,rp) -- Add to hand
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		local g=Duel.GetMatchingGroup(c31006879.filter,tp,LOCATION_DECK,0,nil)
		if #g>0 and not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,e:GetHandler())
			and Duel.SelectYesNo(tp,aux.Stringid(31006879,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
	function c31006879.ctop(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():AddCounter(0x1148,1)
	end
	function c31006879.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return c:IsAbleToGraveAsCost()
			and Duel.IsCanRemoveCounter(tp,1,0,0x1148,2,REASON_COST) end
		Duel.RemoveCounter(tp,1,0,0x1148,2,REASON_COST)
		Duel.SendtoGrave(c,REASON_COST)
	end
	function c31006879.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	end
	function c31006879.drop(e,tp,eg,ep,ev,re,r,rp)
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		if Duel.Draw(p,d,REASON_EFFECT)==2 then
			Duel.ShuffleHand(p)
			Duel.BreakEffect()
			Duel.DiscardHand(p,nil,1,1,REASON_EFFECT)
		end
	end
end
--Terminal World NEXT
if not c48605591 then
	c48605591 = {}
	setmetatable(c48605591, Card)
	rawset(c48605591,"__index",c48605591)
	function c48605591.initial_effect(c)
		--Activate
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCondition(c48605591.condition)
		c:RegisterEffect(e1)
		--
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_MAX_MZONE)
		e2:SetRange(LOCATION_SZONE)
		e2:SetTargetRange(1,1)
		e2:SetValue(c48605591.mvalue)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_MAX_SZONE)
		e3:SetRange(LOCATION_SZONE)
		e3:SetTargetRange(1,1)
		e3:SetValue(c48605591.svalue)
		c:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e4:SetCode(EFFECT_CANNOT_ACTIVATE)
		e4:SetRange(LOCATION_SZONE)
		e4:SetTargetRange(1,1)
		e4:SetValue(c48605591.aclimit)
		c:RegisterEffect(e4)
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e5:SetCode(EFFECT_CANNOT_SSET)
		e5:SetRange(LOCATION_SZONE)
		e5:SetTargetRange(1,1)
		e5:SetTarget(c48605591.setlimit)
		c:RegisterEffect(e5)
	end
	function c48605591.condition(e,tp,eg,ep,ev,re,r,rp)
		return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE|LOCATION_STZONE,0,1,e:GetHandler())
			and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<=3
			and Duel.GetMatchingGroupCount(Card.IsSpellTrap,tp,0,LOCATION_MZONE|LOCATION_STZONE,nil)<=3
	end
	function c48605591.mvalue(e,fp,rp,r)
		if r~=LOCATION_REASON_TOFIELD then return 99 end
		return 3
	end
	function c48605591.svalue(e,fp,rp,r)
		if r~=LOCATION_REASON_TOFIELD then return 99 end
		return 3-Duel.GetFieldGroupCount(fp,LOCATION_FZONE,0)
	end
	function c48605591.aclimit(e,re,tp)
		if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
		if re:IsActiveType(TYPE_FIELD) then
			return not Duel.GetFieldCard(tp,LOCATION_SZONE,5) and Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)>2
		elseif re:IsActiveType(TYPE_PENDULUM) then
			return Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)>2
		end
		return false
	end
	function c48605591.setlimit(e,c,tp)
		return c:IsType(TYPE_FIELD) and not Duel.GetFieldCard(tp,LOCATION_SZONE,5) and Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)>2
	end
end
--Attach field spell

--Laevateinn, Generaider Boss of Shadows
if not c74615388 then
	c74615388 = {}
	setmetatable(c74615388, Card)
	rawset(c74615388,"__index",c74615388)
	function c74615388.initial_effect(c)
		c:EnableReviveLimit()
		c:SetUniqueOnField(1,0,id)
		-- 2+ Level 9 monsters
		Xyz.AddProcedure(c,nil,9,2,nil,nil,99)
		-- Decrease ATK/DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(-1000)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
		-- Special Summon 1 non-Fairy "Generaider" Xyz Monster
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(74615388,0))
		e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_QUICK_O)
		e3:SetCode(EVENT_FREE_CHAIN)
		e3:SetRange(LOCATION_MZONE)
		e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
		e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
		e3:SetCost(c74615388.spcost)
		e3:SetTarget(c74615388.sptg)
		e3:SetOperation(c74615388.spop)
		c:RegisterEffect(e3)
	end
	c74615388.listed_names={74615388}
	c74615388.listed_series={SET_GENERAIDER}
	function c74615388.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return c:IsReleasable() end
		Duel.SetTargetParam(c:GetOverlayCount())
		Duel.Release(c,REASON_COST)
	end
	function c74615388.spfilter(c,e,tp,ec)
		return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_GENERAIDER) and not c:IsRace(RACE_FAIRY)
			and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	function c74615388.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(c74615388.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
	function c74615388.ovfilter(c,xc,tp,e)
		return c:IsCanBeXyzMaterial(xc,tp,REASON_EFFECT) and not c:IsImmuneToEffect(e)
	end
	function c74615388.spop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,c74615388.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		if ct==0 then return end
		local og=Duel.GetMatchingGroup(aux.NecroValleyFilter(c74615388.ovfilter),tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,tc,tc,tp,e)
		if #og==0 or not Duel.SelectYesNo(tp,aux.Stringid(74615388,1)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=og:Select(tp,1,ct,nil)
		if #g>0 then
			for tc in g:Iter() do
				if tc:IsSpellTrap() and tc:IsLocation(LOCATION_SZONE) then
					tc:CancelToGrave()
				end
			end
			Duel.HintSelection(g,true)
			Duel.BreakEffect()
			Duel.Overlay(tc,g,true)
		end
	end
end
--Number 38: Hope Harbinger Dragon Titanic Galaxy
if not c63767246 then
	c63767246 = {}
	setmetatable(c63767246, Card)
	rawset(c63767246,"__index",c63767246)
	function c63767246.initial_effect(c)
		c:EnableReviveLimit()
		--Xyz Summon procedure
		Xyz.AddProcedure(c,nil,8,2)
		--Negate an activated Spell Card or effect
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(63767246,0))
		e1:SetCategory(CATEGORY_DISABLE)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_CHAINING)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(c63767246.discon)
		e1:SetTarget(c63767246.distg)
		e1:SetOperation(c63767246.disop)
		c:RegisterEffect(e1)
		--Change the attack target to this card
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(63767246,1))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()~=e:GetHandler() end)
		e2:SetCost(aux.dxmcostgen(1,1,nil))
		e2:SetOperation(c63767246.chngtgop)
		c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
		--Make 1 of your Xyz monsters gain ATK
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(63767246,2))
		e3:SetCategory(CATEGORY_ATKCHANGE)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e3:SetCode(EVENT_DESTROYED)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCondition(c63767246.atkcon)
		e3:SetTarget(c63767246.atktg)
		e3:SetOperation(c63767246.atkop)
		c:RegisterEffect(e3)
	end
	c63767246.xyz_number=38
	function c63767246.discon(e,tp,eg,ep,ev,re,r,rp)
		local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
		return (loc&LOCATION_SZONE)>0 and re:IsSpellEffect() and Duel.IsChainDisablable(ev)
	end
	function c63767246.distg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	end
	function c63767246.disop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local rc=re:GetHandler()
		if Duel.NegateEffect(ev) and c:IsRelateToEffect(e) and rc:IsRelateToEffect(re) and not rc:IsLocation(LOCATION_FZONE) and c:IsType(TYPE_XYZ) then
			rc:CancelToGrave()
			Duel.Overlay(c,rc,true)
		end
	end
	function c63767246.chngtgop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		local at=Duel.GetAttacker()
		if at:CanAttack() and not at:IsImmuneToEffect(e) then
			Duel.CalculateDamage(at,c)
		end
	end
	function c63767246.atkconfilter(c,tp)
		return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsType(TYPE_XYZ) and c:GetBaseAttack()>0 and c:IsPreviousPosition(POS_FACEUP)
			and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
	end
	function c63767246.atkcon(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(c63767246.atkconfilter,1,nil,tp)
	end
	function c63767246.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsType(TYPE_XYZ) and chkc:IsFaceup() end
		if chk==0 then return eg:IsExists(c63767246.atkconfilter,1,nil,tp)
			and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,1,nil)
	end
	function c63767246.atkop(e,tp,eg,ep,ev,re,r,rp)
		local tc=Duel.GetFirstTarget()
		if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
		local g=eg:Filter(c63767246.atkconfilter,nil,tp)
		if #g>=2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			g=g:Select(tp,1,1,nil)
		end
		--Gains ATK equal to 1 of those destroyed monster's original ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(g:GetFirst():GetBaseAttack())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
--Jormungandr, Generaider Boss of Eternity
if not c2665273 then
	c2665273 = {}
	setmetatable(c2665273, Card)
	rawset(c2665273,"__index",c2665273)
	function c2665273.initial_effect(c)
		c:EnableReviveLimit()
		c:SetUniqueOnField(1,0,2665273)
		Xyz.AddProcedure(c,nil,9,2,nil,nil,99)
		--This card's original ATK/DEF become 1000 x its number of materials
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c2665273.atkval)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		c:RegisterEffect(e2)
		--Each player draws 1 card and attaches 1 card to this card
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(2665273,0))
		e3:SetCategory(CATEGORY_DRAW)
		e3:SetType(EFFECT_TYPE_QUICK_O)
		e3:SetCode(EVENT_FREE_CHAIN)
		e3:SetRange(LOCATION_MZONE)
		e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
		e3:SetCountLimit(1,2665273)
		e3:SetCost(aux.dxmcostgen(1,1,nil))
		e3:SetTarget(c2665273.target)
		e3:SetOperation(c2665273.operation)
		c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	end
	function c2665273.atkval(e,c)
		return c:GetOverlayCount()*1000
	end
	function c2665273.target(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	end
	function c2665273.operation(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local ps={}
		local pc=false
		if Duel.Draw(tp,1,REASON_EFFECT)>0 then
			table.insert(ps,tp)
			pc=true
		end
		if Duel.Draw(1-tp,1,REASON_EFFECT)>0 then
			table.insert(ps,1-tp)
			pc=true
		end
		if not (pc and c:IsRelateToEffect(e) and c:IsFaceup()) then return end
		Duel.BreakEffect()
		for _,p in pairs(ps) do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
			local tc=Duel.SelectMatchingCard(p,Card.IsCanBeXyzMaterial,p,LOCATION_HAND|LOCATION_MZONE|LOCATION_STZONE,0,1,1,c,c,tp,REASON_EFFECT):GetFirst()
			if tc then
				tc:CancelToGrave()
				Duel.Overlay(c,tc,true)
			end
		end
	end
end
