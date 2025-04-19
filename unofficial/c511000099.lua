--レベル・カノン
--Level Cannon
--Fixed/Cleaned up by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    	if chk==0 then return true end
    	local ex,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SUMMON_SUCCESS,true)
    	if not ex then
        	ex,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
        	if not ex then
            		ex,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_FLIP_SUMMON_SUCCESS,true)
        	end
    	end
    	if ex and s.damtg(e,tp,teg,tep,tev,tre,tr,trp,0) then
        	e:SetCategory(CATEGORY_DAMAGE)
        	e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        	e:SetOperation(s.damop)
        	s.damtg(e,tp,teg,tep,tev,tre,tr,trp,1)
    	else
        	e:SetCategory(0)
        	e:SetProperty(0)
        	e:SetOperation(nil)
    	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
    	local tg=eg:Filter(Card.IsFaceup,nil)
    	Duel.SetTargetCard(tg)
    	local b1=tg:IsExists(Card.IsSummonPlayer,1,nil,tp)
    	local b2=tg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
    	local p=b1 and b2 and PLAYER_ALL or b1 and tp or 1-tp
    	Duel.SetTargetPlayer(p)
    	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,tg:GetSum(Card.GetLevel)*200)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    	if not e:GetHandler():IsRelateToEffect(e) then return end
    	local tg=Duel.GetTargetCards(e)
    	if #tg==0 then return end
    	local tpG=tg:Filter(Card.IsSummonPlayer,nil,tp)
    	if #tpG>0 then
        	Duel.Damage(tp,tpG:GetSum(Card.GetLevel)*200,REASON_EFFECT,true)
    	end
    	local opG=tg:Filter(Card.IsSummonPlayer,nil,1-tp)
    	if #opG>0 then
        	Duel.Damage(1-tp,opG:GetSum(Card.GetLevel)*200,REASON_EFFECT,true)
    	end
    	Duel.RDComplete()
end