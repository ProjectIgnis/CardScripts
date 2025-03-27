--共闘闘君
--Token Support
--scripted by Naim
local s,id=GetID()
local TOKEN_ALLIANCE=id+1
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Increase the ATK of a monster by 1000 per Token tributed also it can make up to that many attacks on monsters during each Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Special Summon "Alliance Tokens" up to the number of Token destroyed during the Battle Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and Duel.HasFlagEffect(0,id) end)
	e2:SetTarget(s.tkntg)
	e2:SetOperation(s.tknop)
	c:RegisterEffect(e2)
	--Registers Tokens destroyed during the Battle Phase
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={TOKEN_ALLIANCE} --"Alliance Token"
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsBattlePhase() then return end
	local ct=eg:FilterCount(Card.IsType,nil,TYPE_TOKEN)
	if ct==0 then return end
	for i=1,ct do
		Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_BATTLE,0,1)
	end
end
function s.atkcostfilter(c,tp)
	return c:IsType(TYPE_TOKEN) and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAttack,0),tp,LOCATION_MZONE,0,1,c)
end
function s.spcheck(sg,tp,exg)
	return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAttack,0),tp,LOCATION_MZONE,0,1,sg)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.atkcostfilter,1,false,s.spcheck,nil,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.atkcostfilter,1,99,false,s.spcheck,nil,tp)
	local ct=Duel.Release(g,REASON_COST)
	e:SetLabel(ct)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and chkc:IsFaceup() and chkc:IsAttack(0) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAttack,0),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAttack,0),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,1000*e:GetLabel())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local ct=e:GetLabel()
		--Gains 1000 ATK for each Token Tributed
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*1000)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		if tc:IsFaceup() then
			tc:RegisterEffect(e1)
		end
		--Can make multiple attacks on monsters
		local e2=e1:Clone()
		e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e2:SetValue(ct-1)
		tc:RegisterEffect(e2)
	end
end
function s.tkntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ALLIANCE,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tknop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ALLIANCE,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then return end
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=Duel.AnnounceNumberRange(tp,1,math.min(ft,Duel.GetFlagEffect(0,id)))
	for i=1,ct do
		local token=Duel.CreateToken(tp,TOKEN_ALLIANCE)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end