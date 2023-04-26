--ＣＮｏ．７９ ＢＫ 将星のカエサル
--Number C79: Battlin' Boxer Commander Caesar
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure
	Xyz.AddProcedure(c,nil,5,3)
	--Gain 200 ATK per each material attached
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(_,c) return c:GetOverlayCount()*200 end)
	c:RegisterEffect(e1)
	--Negate Special Summons and destroy that monster(s)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.negsumcond)
	e2:SetTarget(s.negsumtg)
	e2:SetOperation(s.negsumop)
	c:RegisterEffect(e2)
	--Attach monsters when an attack is declared involving a "Battlin' Boxer" monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atchcond)
	e3:SetTarget(s.atchtg)
	e3:SetOperation(s.atchop)
	c:RegisterEffect(e3)
end
s.xyz_number=79
s.listed_names={71921856} --Number 79: Battlin' Boxer Nova Kaiser
s.listed_series={SET_BATTLIN_BOXER}
function s.negsumcond(e,tp,eg,ep,ev,re,r,rp)
	return tp==1-ep and Duel.GetCurrentChain(true)==0
end
function s.negsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.negsumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:RemoveOverlayCard(tp,2,2,REASON_EFFECT) then
		Duel.NegateSummon(eg)
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.atchcond(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,71921856) then return false end
	local a,b=Duel.GetBattleMonster(tp)
	return a and b and a:IsFaceup() and a:IsSetCard(SET_BATTLIN_BOXER)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_BATTLIN_BOXER) and c:IsMonster() and c:IsAbleToGrave()
end
function s.atchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local _,b=Duel.GetBattleMonster(tp)
	if chk==0 then return b:IsAbleToChangeControler()
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.atchop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		local c=e:GetHandler()
		local _,tc=Duel.GetBattleMonster(tp)
		if tc and tc:IsRelateToBattle() and tc:IsControler(1-tp)
			and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) then
			Duel.Overlay(c,tc,true)
		end
	end
end