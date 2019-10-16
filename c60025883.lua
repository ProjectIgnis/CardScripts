--決闘竜 デュエル・リンク・ドラゴン
--Duel Link Dragon
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,2,4,s.lcheck)
	c:EnableReviveLimit()
	--Token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(0)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tkcon)
	e1:SetCost(s.tkcost)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tgcon)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
s.listed_series={0xc2}
s.listed_names={id+1}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO,lc,sumtype,tp)
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.cfilter(c,e,tp,ft,zone)
	local lv=c:GetLevel()
	return (c:IsSetCard(0xc2) or ((c:GetLevel()==7 or c:GetLevel()==8) and c:IsRace(RACE_DRAGON))) 
		and c:IsType(TYPE_SYNCHRO) and lv>0 and c:IsAbleToRemoveAsCost() and ft>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPE_TOKEN+TYPE_MONSTER+TYPE_NORMAL,c:GetAttack(),c:GetDefense(),lv,c:GetRace(),c:GetAttribute()) and Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,zone)>0
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft, zone = Duel.GetLocationCount(tp,LOCATION_MZONE), e:GetHandler():GetLinkedZone()&0x1f
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return ft>-1 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,ft,zone)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ft,zone)
	local tc=g:GetFirst()
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local zone = e:GetHandler():GetLinkedZone()&0x1f
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPE_TOKEN+TYPE_MONSTER+TYPE_NORMAL,tc:GetAttack(),tc:GetDefense(),tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) and Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,zone)>0 then
		local token=Duel.CreateToken(tp,id+1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(tc:GetDefense())
		token:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(tc:GetLevel())
		token:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetValue(tc:GetRace())
		token:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetValue(tc:GetAttribute())
		token:RegisterEffect(e5)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP,zone)
	end 
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsCode(id+1)
end
function s.tgcon(e)
	return Duel.IsExistingMatchingCard(s.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
